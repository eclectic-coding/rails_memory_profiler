require "rails_helper"

RSpec.describe RailsMemoryProfiler::Notifiers::Logger do
  let(:report) do
    { controller: "posts", action: "index", path: "/posts", method: "GET",
      allocated_objects: 2_340, retained_objects: 12, duration_ms: 8.2,
      recorded_at: Time.current }
  end

  it "writes a formatted line to Rails.logger at info level" do
    expect(Rails.logger).to receive(:info).with(/\[RailsMemoryProfiler\].*GET.*\/posts.*2,340 allocated/)
    described_class.new.call(report)
  end
end