require "rails_memory_profiler/test_helper"

if defined?(RSpec)
  RSpec::Matchers.define :allocate_fewer_than do |expected|
    supports_block_expectations

    match do |block|
      @count = RailsMemoryProfiler::TestHelper.capture_allocations(&block)
      @count < expected
    end

    failure_message do
      "expected block to allocate fewer than #{expected} objects, but got #{@count}"
    end

    failure_message_when_negated do
      "expected block to allocate #{expected} or more objects, but got #{@count}"
    end
  end
end
