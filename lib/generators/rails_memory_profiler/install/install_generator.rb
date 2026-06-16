require "rails/generators"

module RailsMemoryProfiler
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates a RailsMemoryProfiler initializer in config/initializers."

      def copy_initializer
        template "initializer.rb", "config/initializers/rails_memory_profiler.rb"
      end

      def show_readme
        say ""
        say "  Mount the dashboard in config/routes.rb:", :green
        say ""
        say '    mount RailsMemoryProfiler::Engine, at: "/rails/memory"'
        say ""
        say "  Then visit /rails/memory/reports to see per-request allocation data.", :green
        say ""
      end
    end
  end
end
