require "rails_helper"

RSpec.describe RailsMemoryProfiler do
  describe ".deprecator" do
    it "returns an ActiveSupport::Deprecation instance" do
      expect(described_class.deprecator).to be_a(ActiveSupport::Deprecation)
    end

    it "is memoized" do
      expect(described_class.deprecator).to be(described_class.deprecator)
    end

    it "is scoped to the gem name and horizon version" do
      deprecator = described_class.deprecator
      expect(deprecator.gem_name).to eq("RailsMemoryProfiler")
      expect(deprecator.deprecation_horizon).to eq("1.0.0")
    end
  end
end