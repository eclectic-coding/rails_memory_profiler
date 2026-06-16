module RailsMemoryProfiler
  module RequestContext
    class << self
      def set(controller:, action:, path:, method:)
        Thread.current[:rails_memory_profiler_context] = {
          controller: controller,
          action: action,
          path: path,
          method: method
        }
      end

      def current
        Thread.current[:rails_memory_profiler_context] || {}
      end

      def clear
        Thread.current[:rails_memory_profiler_context] = nil
      end
    end
  end
end
