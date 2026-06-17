require "turbo-rails"
require "importmap-rails"

module RailsMemoryProfiler
  class Engine < ::Rails::Engine
    isolate_namespace RailsMemoryProfiler
    config.generators.api_only = true

    MOUNT_PATH_MUTEX = Mutex.new
    private_constant :MOUNT_PATH_MUTEX

    class << self
      # Returns the path at which the engine is mounted in the host application,
      # e.g. +"/rails/memory"+. Detected lazily on first call by scanning
      # +Rails.application.routes+, then cached. Returns +nil+ if the engine is
      # not mounted.
      #
      # @return [String, nil]
      def mount_path
        return @mount_path if @mount_path

        MOUNT_PATH_MUTEX.synchronize do
          @mount_path ||= begin
            mounted = Rails.application.routes.routes.find do |route|
              route.app.app == self rescue false
            end
            mounted&.path&.spec&.to_s&.gsub(/\([^)]*\)/, "")
          end
        end
      end

      # Clears the cached mount path so it will be re-detected on the next call.
      # Primarily used in tests.
      #
      # @return [void]
      def reset_mount_path!
        MOUNT_PATH_MUTEX.synchronize { @mount_path = nil }
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
