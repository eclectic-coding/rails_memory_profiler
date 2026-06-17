require "rails_helper"

RSpec.describe RailsMemoryProfiler::Notifiers::Console do
  let(:report) do
    { controller: "posts", action: "index", path: "/posts", method: "GET",
      allocated_objects: allocated, retained_objects: 12, duration_ms: 8.2,
      recorded_at: Time.current }
  end

  shared_examples "colorized output" do |expected_color|
    it "writes ANSI-colorized output to $stdout with #{expected_color} for allocation count" do
      output = nil
      allow($stdout).to receive(:puts) { |s| output = s }
      described_class.new.call(report)
      expect(output).to include("\e[")
      expect(output).to include(expected_color)
      expect(output).to include("GET")
      expect(output).to include("/posts")
    end
  end

  context "with low allocations (< 5,000)" do
    let(:allocated) { 2_340 }
    include_examples "colorized output", "\e[32m"
  end

  context "with mid allocations (5,000–19,999)" do
    let(:allocated) { 10_000 }
    include_examples "colorized output", "\e[33m"
  end

  context "with high allocations (>= 20,000)" do
    let(:allocated) { 25_000 }
    include_examples "colorized output", "\e[31m"
  end
end