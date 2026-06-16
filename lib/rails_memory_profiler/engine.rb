module RailsMemoryProfiler
  class Engine < ::Rails::Engine
    isolate_namespace RailsMemoryProfiler
    config.generators.api_only = true

    initializer "rails_memory_profiler.middleware" do |app|
      app.middleware.use(Middleware)
    end
  end
end
