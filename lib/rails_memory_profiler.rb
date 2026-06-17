require "rails_memory_profiler/version"
require "rails_memory_profiler/configuration"
require "rails_memory_profiler/report_store"
require "rails_memory_profiler/notifiers"
require "rails_memory_profiler/middleware"
require "rails_memory_profiler/engine"

module RailsMemoryProfiler
  class AllocationSpikeError < StandardError; end

  class << self
    def configure
      yield config
    end

    def config
      @config ||= Configuration.new
    end

    def reset_config!
      @config = Configuration.new
    end

    def deprecator
      @deprecator ||= ActiveSupport::Deprecation.new("1.0.0", "RailsMemoryProfiler")
    end
  end
end
