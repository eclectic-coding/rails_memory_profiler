module RailsMemoryProfiler
  module Notifiers
    class Logger
      def call(report)
        Rails.logger.info(Notifiers.format_line(report))
      end
    end
  end
end
