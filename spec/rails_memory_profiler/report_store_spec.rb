require "rails_helper"

RSpec.describe RailsMemoryProfiler::ReportStore do
  let(:report) do
    {
      controller: "posts",
      action: "index",
      path: "/posts",
      method: "GET",
      allocated_objects: 1200,
      retained_objects: 40,
      duration_ms: 12.5,
      recorded_at: Time.current
    }
  end

  before do
    described_class.clear
    RailsMemoryProfiler.reset_config!
  end

  after { described_class.clear }

  describe ".push and .all" do
    it "stores a report and returns it" do
      described_class.push(report)

      expect(described_class.all).to eq([report])
    end

    it "preserves insertion order" do
      3.times { |i| described_class.push(report.merge(path: "/posts/#{i}")) }

      paths = described_class.all.map { |r| r[:path] }
      expect(paths).to eq(["/posts/0", "/posts/1", "/posts/2"])
    end
  end

  describe ".size" do
    it "returns 0 when empty" do
      expect(described_class.size).to eq(0)
    end

    it "returns the number of stored reports" do
      described_class.push(report)
      described_class.push(report)

      expect(described_class.size).to eq(2)
    end
  end

  describe ".clear" do
    it "empties the store" do
      described_class.push(report)
      described_class.clear

      expect(described_class.all).to eq([])
      expect(described_class.size).to eq(0)
    end
  end

  describe "circular buffer behaviour" do
    it "evicts the oldest report when capacity is exceeded" do
      RailsMemoryProfiler.config.store_size = 3
      described_class.clear

      4.times { |i| described_class.push(report.merge(path: "/posts/#{i}")) }

      paths = described_class.all.map { |r| r[:path] }
      expect(paths).to eq(["/posts/1", "/posts/2", "/posts/3"])
      expect(described_class.size).to eq(3)
    end
  end
end