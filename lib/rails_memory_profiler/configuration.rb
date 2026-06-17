module RailsMemoryProfiler
  class Configuration
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
