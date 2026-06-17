require "turbo-rails"
require "importmap-rails"

module RailsMemoryProfiler
  class Engine < ::Rails::Engine
    isolate_namespace RailsMemoryProfiler
    config.generators.api_only = true

    class << self
      def mount_path
        @mount_path ||= begin
          mounted = Rails.application.routes.routes.find do |route|
            route.app.app == self rescue false
          end
          mounted&.path&.spec&.to_s&.gsub(/\([^)]*\)/, "")
        end
      end

      def reset_mount_path!
        @mount_path = nil
      end
    end

    initializer "rails_memory_profiler.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app/javascript")
      end
    end

    initializer "rails_memory_profiler.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
      end
    end

    initializer "rails_memory_profiler.middleware" do |app|
      app.middleware.use(Middleware)
    end
  end
end
