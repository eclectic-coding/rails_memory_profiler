module RailsMemoryProfiler
  # Holds all user-facing settings. Obtain the shared instance via
  # {RailsMemoryProfiler.config} or set values inside a {RailsMemoryProfiler.configure} block.
  #
  # @example
  #   RailsMemoryProfiler.configure do |config|
  #     config.sample_rate           = 5
  #     config.min_allocated_objects = 1_000
  #     config.notifiers             = [RailsMemoryProfiler::Notifiers::Console.new]
  #   end
  class Configuration
    # @!attribute enabled
    #   Enable or disable per-request profiling. Defaults to +true+ in development.
    #   @return [Boolean]

    # @!attribute sample_rate
    #   Profile every Nth request. +1+ profiles every request.
    #   @return [Integer]

    # @!attribute store_size
    #   Maximum number of reports kept in the ring buffer. Oldest are evicted when full.
    #   @return [Integer]

    # @!attribute dashboard_enabled
    #   Enable the HTML/JSON dashboard endpoint. Defaults to +true+ in development.
    #   @return [Boolean]

    # @!attribute min_allocated_objects
    #   Skip recording requests that allocate fewer objects than this threshold.
    #   @return [Integer]

    # @!attribute ignore_paths
    #   Paths to skip entirely. Accepts strings (prefix match) or Regexps.
    #   The engine's own mount path is always ignored regardless of this setting.
    #   @return [Array<String, Regexp>]

    # @!attribute ignore_controllers
    #   Controller names to skip (matched against the Rails controller name string).
    #   @return [Array<String>]

    # @!attribute detailed_reports
    #   Capture full +MemoryProfiler.report+ breakdowns (by gem, class, file, location).
    #   Requires +gem "memory_profiler"+ in the host app's Gemfile.
    #   @return [Boolean]

    # @!attribute detailed_sample_rate
    #   When {#detailed_reports} is enabled, capture a full report every Nth profiled request.
    #   @return [Integer]

    # @!attribute raise_on_allocation_spike
    #   Raise {RailsMemoryProfiler::AllocationSpikeError} when allocated objects exceed this value.
    #   Set to +nil+ to disable. Intended for use in test environments.
    #   @return [Integer, nil]

    # @!attribute notifiers
    #   Array of notifier objects, each responding to +#call(report)+. Called after
    #   each report is stored. Built-in options: {Notifiers::Logger}, {Notifiers::Stdout},
    #   {Notifiers::Console}, {Notifiers::FileLogger}.
    #   @return [Array<#call>]

    # @!attribute log_file
    #   Path to a file where reports are appended as JSON lines. Shortcut for
    #   configuring {Notifiers::FileLogger} manually.
    #   @return [String, nil]

    attr_accessor :enabled, :sample_rate, :store_size, :dashboard_enabled,
                  :min_allocated_objects, :ignore_paths, :ignore_controllers,
                  :detailed_reports, :detailed_sample_rate,
                  :raise_on_allocation_spike,
                  :notifiers, :log_file

    def initialize
      @enabled               = Rails.env.development?
      @sample_rate           = 1
      @store_size            = 100
      @dashboard_enabled     = Rails.env.development?
      @min_allocated_objects = 0
      @ignore_paths          = []
      @ignore_controllers    = []
      @detailed_reports          = false
      @detailed_sample_rate      = 10
      @raise_on_allocation_spike = nil
      @notifiers                 = []
      @log_file                  = nil
    end
  end
end
