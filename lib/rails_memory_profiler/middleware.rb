module RailsMemoryProfiler
  class Middleware
    def initialize(app)
      @app           = app
      @request_count = 0
      @mutex         = Mutex.new
    end

    def call(env)
      return @app.call(env) unless RailsMemoryProfiler.config.enabled
      return @app.call(env) if ignored_path?(env["PATH_INFO"])
      return @app.call(env) unless sample?

      profile(env)
    end

    private

      def profile(env)
        start          = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        before_alloc   = GC.stat[:total_allocated_objects]
        before_freed   = GC.stat[:total_freed_objects]

        status, headers, body = @app.call(env)

        after_alloc  = GC.stat[:total_allocated_objects]
        after_freed  = GC.stat[:total_freed_objects]
        duration_ms  = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)

        allocated_objects = after_alloc - before_alloc
        retained_objects  = (after_alloc - after_freed) - (before_alloc - before_freed)

        if allocated_objects >= RailsMemoryProfiler.config.min_allocated_objects
          params     = env["action_dispatch.request.path_parameters"] || {}
          controller = params[:controller]

          unless ignored_controller?(controller)
            ReportStore.push(
              controller: controller,
              action: params[:action],
              path: env["PATH_INFO"],
              method: env["REQUEST_METHOD"],
              duration_ms: duration_ms,
              allocated_objects: allocated_objects,
              retained_objects: [retained_objects, 0].max,
              recorded_at: Time.current
            )
          end
        end

        [status, headers, body]
      end

      def sample?
        rate = RailsMemoryProfiler.config.sample_rate
        return true if rate <= 1

        @mutex.synchronize do
          @request_count = (@request_count + 1) % rate
          @request_count.zero?
        end
      end

      def ignored_path?(path)
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
