module RailsMemoryProfiler
  class Engine < ::Rails::Engine
    isolate_namespace RailsMemoryProfiler
    config.generators.api_only = true
  end
end
