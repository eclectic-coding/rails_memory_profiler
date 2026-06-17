require "rails_memory_profiler/test_helper"

if defined?(Minitest)
  module RailsMemoryProfiler
    module MinitestMatchers
      def assert_allocates_fewer_than(threshold, msg = nil, &block)
        count = RailsMemoryProfiler::TestHelper.capture_allocations(&block)
        message = msg || "Expected fewer than #{threshold} allocated objects but got #{count}"
        assert count < threshold, message
      end
    end
  end

  Minitest::Test.include RailsMemoryProfiler::MinitestMatchers
end
