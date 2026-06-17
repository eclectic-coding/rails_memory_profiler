require "rails_helper"

RSpec.describe RailsMemoryProfiler::Configuration do
  subject(:config) { described_class.new }

  describe "defaults" do
    it { expect(config.enabled).to be(false) }
    it { expect(config.sample_rate).to eq(1) }
    it { expect(config.store_size).to eq(100) }
    it { expect(config.dashboard_enabled).to be(false) }
    it { expect(config.min_allocated_objects).to eq(0) }
    it { expect(config.ignore_paths).to eq([]) }
    it { expect(config.ignore_controllers).to eq([]) }
    it { expect(config.detailed_reports).to be(false) }
    it { expect(config.detailed_sample_rate).to eq(10) }
    it { expect(config.raise_on_allocation_spike).to be_nil }
  end

  describe "assignment" do
    it "accepts all configuration options" do
      config.enabled               = true
      config.sample_rate           = 10
      config.store_size            = 50
      config.dashboard_enabled     = true
      config.min_allocated_objects = 500
      config.ignore_paths          = ["/health"]
      config.ignore_controllers    = ["rails_memory_profiler/reports"]
      config.detailed_reports          = true
      config.detailed_sample_rate      = 5
      config.raise_on_allocation_spike = 5_000

      expect(config.enabled).to be(true)
      expect(config.sample_rate).to eq(10)
      expect(config.store_size).to eq(50)
      expect(config.dashboard_enabled).to be(true)
      expect(config.min_allocated_objects).to eq(500)
      expect(config.ignore_paths).to eq(["/health"])
      expect(config.ignore_controllers).to eq(["rails_memory_profiler/reports"])
      expect(config.detailed_reports).to be(true)
      expect(config.detailed_sample_rate).to eq(5)
      expect(config.raise_on_allocation_spike).to eq(5_000)
    end
  end
end