module RailsMemoryProfiler
  class Configuration
    attr_accessor :enabled, :sample_rate, :store_size, :dashboard_enabled,
                  :min_allocated_objects, :ignore_paths, :ignore_controllers

    def initialize
      @enabled               = Rails.env.development?
      @sample_rate           = 1
      @store_size            = 100
      @dashboard_enabled     = Rails.env.development?
      @min_allocated_objects = 0
      @ignore_paths          = []
      @ignore_controllers    = []
    end
  end
end
