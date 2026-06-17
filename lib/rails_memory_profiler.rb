require "rails_memory_profiler/version"
require "rails_memory_profiler/configuration"
require "rails_memory_profiler/report_store"
require "rails_memory_profiler/notifiers"
require "rails_memory_profiler/middleware"
require "rails_memory_profiler/engine"

# RailsMemoryProfiler is a Rails engine that captures per-request object
# allocations via GC.stat diffs and serves them through a mountable dashboard.
#
# @example Mounting the engine
#   # config/routes.rb
#   mount RailsMemoryProfiler::Engine, at: "/rails/memory"
#
# @example Configuring the gem
#   RailsMemoryProfiler.configure do |config|
#     config.sample_rate           = 5
#     config.min_allocated_objects = 1_000
#   end
module RailsMemoryProfiler
  # Raised by the middleware when allocated objects exceed
  # {Configuration#raise_on_allocation_spike}.
  class AllocationSpikeError < StandardError; end

  class << self
    # Yields the {Configuration} instance for block-style setup.
    #
    # @yieldparam config [Configuration]
    # @return [void]
    def configure
      yield config
    end

    # Returns the shared {Configuration} instance, creating it on first call.
    #
    # @return [Configuration]
    def config
      @config ||= Configuration.new
    end

    # Replaces the shared {Configuration} instance with a fresh default.
    # Primarily used in tests.
    #
    # @return [Configuration]
    def reset_config!
      @config = Configuration.new
    end

    # Returns a memoized +ActiveSupport::Deprecation+ instance scoped to this
    # gem. Use it to emit deprecation warnings for any future breaking changes
    # rather than calling +warn+ directly.
    #
    # @return [ActiveSupport::Deprecation]
    def deprecator
      @deprecator ||= ActiveSupport::Deprecation.new("1.0.0", "RailsMemoryProfiler")
    end
  end
end
