module RailsMemoryProfiler
  # Rack middleware that profiles each request and pushes a report into {ReportStore}.
  # Registered automatically by the {Engine} initializer; you do not need to add it
  # to the middleware stack manually.
  #
  # Profiling is skipped when:
  # - {Configuration#enabled} is +false+
  # - the request path matches {Configuration#ignore_paths} or the engine mount path
  # - the request is not selected by {Configuration#sample_rate}
  class Middleware
    # @param app [#call] the next Rack application in the stack
    def initialize(app)
      @app            = app
      @request_count  = 0
      @detailed_count = 0
      @mutex          = Mutex.new
    end

    # Profiles the request if applicable and delegates to the inner app.
    #
    # @param env [Hash] Rack environment
    # @return [Array] Rack response triplet
    def call(env)
      return @app.call(env) unless RailsMemoryProfiler.config.enabled
      return @app.call(env) if ignored_path?(env["PATH_INFO"])
      return @app.call(env) unless sample?

      profile(env)
    end

    private

      def profile(env)
        config = RailsMemoryProfiler.config
        if config.detailed_reports && detailed_sample?
          profile_detailed(env)
        else
          profile_basic(env)
        end
      end

      def profile_basic(env)
        start        = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        before_alloc = GC.stat[:total_allocated_objects]
        before_freed = GC.stat[:total_freed_objects]

        status, headers, body = @app.call(env)

        after_alloc = GC.stat[:total_allocated_objects]
        after_freed = GC.stat[:total_freed_objects]
        duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)

        allocated_objects = after_alloc - before_alloc
        retained_objects  = (after_alloc - after_freed) - (before_alloc - before_freed)

        push_report(env, duration_ms, allocated_objects, retained_objects)

        [status, headers, body]
      end

      def profile_detailed(env)
        require_memory_profiler!

        start  = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        result = nil

        memory_report = MemoryProfiler.report { result = @app.call(env) }

        duration_ms       = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)
        allocated_objects = memory_report.total_allocated
        retained_objects  = memory_report.total_retained

        detail = {
          allocated_by_gem:      serialize_stats(memory_report.allocated_objects_by_gem),
          allocated_by_file:     serialize_stats(memory_report.allocated_objects_by_file),
          allocated_by_class:    serialize_stats(memory_report.allocated_objects_by_class),
          allocated_by_location: serialize_stats(memory_report.allocated_objects_by_location),
          retained_by_gem:       serialize_stats(memory_report.retained_objects_by_gem),
          retained_by_file:      serialize_stats(memory_report.retained_objects_by_file),
          retained_by_class:     serialize_stats(memory_report.retained_objects_by_class),
          retained_by_location:  serialize_stats(memory_report.retained_objects_by_location)
        }

        push_report(env, duration_ms, allocated_objects, retained_objects, detail)

        result
      end

      def push_report(env, duration_ms, allocated_objects, retained_objects, detail = nil)
        return if allocated_objects < RailsMemoryProfiler.config.min_allocated_objects

        params     = env["action_dispatch.request.path_parameters"] || {}
        controller = params[:controller]
        return if ignored_controller?(controller)

        payload = {
          controller: controller,
          action: params[:action],
          path: env["PATH_INFO"],
          method: env["REQUEST_METHOD"],
          duration_ms: duration_ms,
          allocated_objects: allocated_objects,
          retained_objects: [retained_objects, 0].max,
          recorded_at: Time.current
        }
        payload[:detail] = detail if detail

        ReportStore.push(payload)
        notify!(payload)
        check_spike!(allocated_objects, env)
      end

      def notify!(report)
        RailsMemoryProfiler.config.notifiers.each { |n| n.call(report) }
        if (path = RailsMemoryProfiler.config.log_file)
          Notifiers::FileLogger.new(path).call(report)
        end
      end

      def check_spike!(allocated_objects, env)
        threshold = RailsMemoryProfiler.config.raise_on_allocation_spike
        return unless threshold && allocated_objects > threshold

        raise AllocationSpikeError,
          "#{env['PATH_INFO']} allocated #{allocated_objects} objects (threshold: #{threshold})"
      end

      def serialize_stats(stats)
        stats.map { |s| { name: s[:data], count: s[:count] } }
      end

      def require_memory_profiler!
        require "memory_profiler"
      rescue LoadError
        raise LoadError, "Add `gem 'memory_profiler'` to your Gemfile to use config.detailed_reports = true"
      end

      def sample?
        rate = RailsMemoryProfiler.config.sample_rate
        return true if rate <= 1

        @mutex.synchronize do
          @request_count = (@request_count + 1) % rate
          @request_count.zero?
        end
      end

      def detailed_sample?
        rate = RailsMemoryProfiler.config.detailed_sample_rate
        return true if rate <= 1

        @mutex.synchronize do
          @detailed_count = (@detailed_count + 1) % rate
          @detailed_count.zero?
        end
      end

      def ignored_path?(path)
        mount = RailsMemoryProfiler::Engine.mount_path
        return true if mount && path.start_with?(mount)

        RailsMemoryProfiler.config.ignore_paths.any? do |pattern|
          pattern.is_a?(Regexp) ? pattern.match?(path) : path.start_with?(pattern.to_s)
        end
      end

      def ignored_controller?(controller)
        return false unless controller

        RailsMemoryProfiler.config.ignore_controllers.any? { |name| name.to_s == controller }
      end
  end
end
