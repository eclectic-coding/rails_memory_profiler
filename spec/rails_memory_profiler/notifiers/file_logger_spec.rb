require "rails_helper"
require "tempfile"
require "json"

RSpec.describe RailsMemoryProfiler::Notifiers::FileLogger do
  let(:report) do
    { controller: "posts", action: "index", path: "/posts", method: "GET",
      allocated_objects: 2_340, retained_objects: 12, duration_ms: 8.2,
      recorded_at: Time.current }
  end

  it "appends a JSON line to the configured file" do
    Tempfile.create("rmp_log") do |f|
      described_class.new(f.path).call(report)
      data = JSON.parse(File.read(f.path).strip)
      expect(data["path"]).to eq("/posts")
      expect(data["allocated_objects"]).to eq(2_340)
      expect(data["recorded_at"]).to be_a(String)
    end
  end

  it "appends multiple reports as separate JSON lines" do
    Tempfile.create("rmp_log") do |f|
      notifier = described_class.new(f.path)
      notifier.call(report)
      notifier.call(report.merge(path: "/users"))
      lines = File.readlines(f.path).map { |l| JSON.parse(l) }
      expect(lines.size).to eq(2)
      expect(lines.last["path"]).to eq("/users")
    end
  end
end