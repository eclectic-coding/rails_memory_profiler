require "rails_memory_profiler/notifiers/logger"
require "rails_memory_profiler/notifiers/stdout"
require "rails_memory_profiler/notifiers/console"
require "rails_memory_profiler/notifiers/file_logger"

module RailsMemoryProfiler
  module Notifiers
    def self.format_line(report)
      action = [report[:controller], report[:action]].compact.join("#")
      "[RailsMemoryProfiler] #{report[:method]} #{report[:path]} (#{action})" \
        " — #{thousands(report[:allocated_objects])} allocated," \
        " #{report[:retained_objects]} retained, #{report[:duration_ms]}ms"
    end

    def self.thousands(n)
      n.to_s.reverse.scan(/\d{1,3}/).join(",").reverse
    end
  end
end
