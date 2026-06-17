module RailsMemoryProfiler
  module Notifiers
    class Stdout
      def call(report)
        $stdout.puts(Notifiers.format_line(report))
      end
    end
  end
end
