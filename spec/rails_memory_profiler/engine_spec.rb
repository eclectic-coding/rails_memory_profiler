require "rails_helper"

RSpec.describe RailsMemoryProfiler::Engine do
  describe ".mount_path" do
    it "returns the engine mount point" do
      expect(described_class.mount_path).to eq("/rails/memory")
    end

    it "re-detects after reset_mount_path!" do
      described_class.reset_mount_path!
      expect(described_class.mount_path).to eq("/rails/memory")
    end
  end
end