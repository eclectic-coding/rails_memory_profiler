require "rails_memory_profiler"

module RailsMemoryProfiler
  module TestHelper
    extend self

    def capture_allocations
      GC.start
      before = GC.stat(:total_allocated_objects)
      yield
      GC.stat(:total_allocated_objects) - before
    end

    def assert_allocations_below(threshold, &block)
      count = capture_allocations(&block)
      return if count < threshold

      raise "Expected fewer than #{threshold} allocated objects but got #{count}"
    end
  end
end
