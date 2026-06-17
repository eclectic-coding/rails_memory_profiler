require "rails_helper"
require "rails_memory_profiler/test_helper"

RSpec.describe RailsMemoryProfiler::TestHelper do
  subject(:helper) { Object.new.tap { |o| o.extend(described_class) } }

  describe "#capture_allocations" do
    it "returns an integer count of allocated objects" do
      count = helper.capture_allocations { Array.new(100) { Object.new } }
      expect(count).to be_a(Integer)
      expect(count).to be > 0
    end

    it "returns a low count for a nearly allocation-free block" do
      count = helper.capture_allocations { 1 + 1 }
      expect(count).to be < 100
    end
  end

  describe "#assert_allocations_below" do
    it "does not raise when allocations are below the threshold" do
      expect { helper.assert_allocations_below(1_000_000) { "x" } }.not_to raise_error
    end

    it "raises Minitest::Assertion with a descriptive message when allocations exceed the threshold" do
      expect {
        helper.assert_allocations_below(1) { Array.new(1_000) { Object.new } }
      }.to raise_error(Minitest::Assertion, /fewer than 1/)
    end

    it "raises RuntimeError when Minitest is not available" do
      allow(Object).to receive(:const_defined?).with(:Minitest).and_return(false)
      expect {
        helper.assert_allocations_below(1) { Array.new(1_000) { Object.new } }
      }.to raise_error(RuntimeError, /fewer than 1/)
    end
  end

  describe "module_function interface" do
    it "can be called directly on the module" do
      count = described_class.capture_allocations { "x" * 10 }
      expect(count).to be_a(Integer)
    end
  end
end