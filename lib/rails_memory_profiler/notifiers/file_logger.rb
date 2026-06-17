require "json"

module RailsMemoryProfiler
  module Notifiers
    class FileLogger
      def initialize(path)
        @path = path
      end

      def call(report)
        serializable = report.merge(recorded_at: report[:recorded_at]&.iso8601)
        File.open(@path, "a") { |f| f.puts(serializable.to_json) }
      end
    end
  end
end
