require "rails_memory_profiler"

module RailsMemoryProfiler
  # Utility methods for asserting allocation counts in tests.
  # Not auto-required — opt in with:
  #
  #   require "rails_memory_profiler/test_helper"
  #
  # Works as a module-level call or mixed into a test class via +include+/+extend+:
  #
  #   include RailsMemoryProfiler::TestHelper
  #
  # For RSpec block expectations see {file:lib/rails_memory_profiler/rspec_matchers.rb}.
  # For Minitest assertions see {file:lib/rails_memory_profiler/minitest_matchers.rb}.
  module TestHelper
    extend self

    # Runs the block and returns the number of Ruby objects allocated during it.
    # Triggers a full GC before measuring to reduce noise from prior allocations.
    #
    # @yieldreturn [Object] the block's return value is discarded
    # @return [Integer] number of objects allocated
    def capture_allocations
      GC.start
      before = GC.stat(:total_allocated_objects)
      yield
      GC.stat(:total_allocated_objects) - before
    end

    # Asserts that the block allocates fewer than +threshold+ objects.
    # Raises +Minitest::Assertion+ when Minitest is loaded (so the failure is
    # reported as a test failure rather than an error), otherwise raises +RuntimeError+.
    #
    # @param threshold [Integer] maximum acceptable allocation count
    # @yieldreturn [Object] the block's return value is discarded
    # @raise [Minitest::Assertion] when Minitest is present and the threshold is exceeded
    # @raise [RuntimeError] when Minitest is absent and the threshold is exceeded
    # @return [void]
    def assert_allocations_below(threshold, &block)
      count = capture_allocations(&block)
      return if count < threshold

      message = "Expected fewer than #{threshold} allocated objects but got #{count}"
      error_class = Object.const_defined?(:Minitest) ? Minitest::Assertion : RuntimeError
      raise error_class, message
    end
  end
end
