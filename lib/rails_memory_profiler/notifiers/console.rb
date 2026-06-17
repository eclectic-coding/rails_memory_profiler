module RailsMemoryProfiler
  module Notifiers
    class Console
      RESET  = "\e[0m"
      CYAN   = "\e[36m"
      DIM    = "\e[2m"
      GREEN  = "\e[32m"
      YELLOW = "\e[33m"
      RED    = "\e[31m"

      def call(report)
        $stdout.puts(colorize(report))
      end

      private

        def colorize(report)
          action = [report[:controller], report[:action]].compact.join("#")
          alloc  = report[:allocated_objects]

          "#{DIM}[RMP]#{RESET} " \
          "#{CYAN}#{report[:method]} #{report[:path]}#{RESET} " \
          "#{DIM}(#{action})#{RESET}  " \
          "#{alloc_color(alloc)}#{Notifiers.thousands(alloc)} alloc#{RESET}  " \
          "#{DIM}#{report[:retained_objects]} retained  #{report[:duration_ms]}ms#{RESET}"
        end

        def alloc_color(count)
          if count < 5_000 then GREEN
          elsif count < 20_000 then YELLOW
          else RED
          end
        end
    end
  end
end
