require "rails_helper"
require "rails_memory_profiler/rspec_matchers"

RSpec.describe "allocate_fewer_than matcher" do
  it "passes when the block allocates fewer objects than the threshold" do
    expect { "x" * 10 }.to allocate_fewer_than(100_000)
  end

  it "fails when the block allocates more objects than the threshold" do
    expect {
      expect { Array.new(1_000) { Object.new } }.to allocate_fewer_than(1)
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /fewer than 1/)
  end

  it "supports negation" do
    expect { Array.new(1_000) { Object.new } }.not_to allocate_fewer_than(1)
  end

  it "provides a negation failure message when the block does allocate fewer than expected" do
    expect {
      expect { "x" }.not_to allocate_fewer_than(100_000)
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /or more/)
  end
end