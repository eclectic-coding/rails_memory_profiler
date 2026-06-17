require "rails_helper"

RSpec.describe "RailsMemoryProfiler::Store", type: :request do
  let(:report) do
    {
      controller: "posts",
      action: "index",
      path: "/posts",
      method: "GET",
      allocated_objects: 8_500,
      retained_objects: 120,
      duration_ms: 18.4,
      recorded_at: Time.current
    }
  end

  before do
    RailsMemoryProfiler.reset_config!
    RailsMemoryProfiler.config.dashboard_enabled = true
    RailsMemoryProfiler::ReportStore.clear
  end

  after { RailsMemoryProfiler::ReportStore.clear }

  describe "DELETE /rails/memory/store" do
    it "clears the store and redirects to reports index" do
      RailsMemoryProfiler::ReportStore.push(report)
      expect { delete "/rails/memory/store" }
        .to change { RailsMemoryProfiler::ReportStore.size }.from(1).to(0)
      expect(response).to redirect_to("/rails/memory/reports")
    end

    it "returns 403 when dashboard is disabled" do
      RailsMemoryProfiler.config.dashboard_enabled = false
      delete "/rails/memory/store"
      expect(response).to have_http_status(:forbidden)
    end
  end
end