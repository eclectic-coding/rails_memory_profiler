require "rails_helper"

RSpec.describe RailsMemoryProfiler::ApplicationHelper, type: :helper do
  describe "#allocation_badge" do
    it "renders a low badge for counts under 5,000" do
      html = helper.allocation_badge(4_999)
      expect(html).to include("rmp-badge--low")
      expect(html).to include("4,999")
    end

    it "renders a mid badge for counts between 5,000 and 19,999" do
      html = helper.allocation_badge(10_000)
      expect(html).to include("rmp-badge--mid")
      expect(html).to include("10,000")
    end

    it "renders a high badge for counts of 20,000 or more" do
      html = helper.allocation_badge(20_000)
      expect(html).to include("rmp-badge--high")
      expect(html).to include("20,000")
    end
  end
end