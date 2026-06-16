require "rails_helper"

RSpec.describe RailsMemoryProfiler do
  before { described_class.reset_config! }
  after  { described_class.reset_config! }

  describe ".configure" do
    it "yields the configuration object" do
      described_class.configure do |config|
        config.enabled    = true
        config.store_size = 50
      end

      expect(described_class.config.enabled).to be(true)
      expect(described_class.config.store_size).to eq(50)
    end
  end

  describe ".reset_config!" do
    it "resets to a fresh Configuration" do
      described_class.config.store_size = 999
      described_class.reset_config!

      expect(described_class.config.store_size).to eq(100)
    end
  end
end