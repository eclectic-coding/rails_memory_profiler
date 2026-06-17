require "rails_helper"
require "rails_memory_profiler/minitest_matchers"

RSpec.describe RailsMemoryProfiler::MinitestMatchers do
  subject(:test_case) { Class.new(Minitest::Test).new("test_0001_placeholder") }

  describe "#assert_allocates_fewer_than" do
    it "passes when allocations are below the threshold" do
      expect { test_case.assert_allocates_fewer_than(1_000_000) { "x" } }.not_to raise_error
    end

    it "raises Minitest::Assertion when allocations exceed the threshold" do
      expect {
        test_case.assert_allocates_fewer_than(1) { Array.new(1_000) { Object.new } }
      }.to raise_error(Minitest::Assertion, /fewer than 1/)
    end

    it "accepts an optional failure message" do
      expect {
        test_case.assert_allocates_fewer_than(1, "too many!") { Array.new(1_000) { Object.new } }
      }.to raise_error(Minitest::Assertion, /too many!/)
    end
  end

  describe "auto-inclusion into Minitest::Test" do
    it "is available on Minitest::Test instances" do
      expect(test_case).to respond_to(:assert_allocates_fewer_than)
    end
  end
end