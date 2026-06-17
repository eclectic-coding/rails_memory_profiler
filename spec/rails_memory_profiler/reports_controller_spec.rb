require "rails_helper"

RSpec.describe "RailsMemoryProfiler::Reports", type: :request do
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

  describe "GET /rails/memory/reports" do
    it "returns 200 HTML" do
      get "/rails/memory/reports"
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/html")
    end

    it "returns 200 JSON" do
      RailsMemoryProfiler::ReportStore.push(report)
      get "/rails/memory/reports", headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data.first["path"]).to eq("/posts")
    end

    it "returns 403 when dashboard is disabled" do
      RailsMemoryProfiler.config.dashboard_enabled = false
      get "/rails/memory/reports"
      expect(response).to have_http_status(:forbidden)
    end

    context "with stored reports" do
      before { 3.times { |i| RailsMemoryProfiler::ReportStore.push(report.merge(path: "/posts/#{i}", allocated_objects: i * 1_000)) } }

      it "sorts ascending when direction=asc" do
        get "/rails/memory/reports?sort=allocated_objects&direction=asc"
        expect(response).to have_http_status(:ok)
      end

      it "sorts descending by default" do
        get "/rails/memory/reports?sort=allocated_objects"
        expect(response).to have_http_status(:ok)
      end

      it "ignores unknown sort columns" do
        get "/rails/memory/reports?sort=evil_column"
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /rails/memory/reports/:id" do
    context "when the report exists" do
      before { RailsMemoryProfiler::ReportStore.push(report) }

      it "returns 200 HTML" do
        id = RailsMemoryProfiler::ReportStore.all.first[:id]
        get "/rails/memory/reports/#{id}"
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("text/html")
      end

      it "returns the report as JSON" do
        id = RailsMemoryProfiler::ReportStore.all.first[:id]
        get "/rails/memory/reports/#{id}", headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data["path"]).to eq("/posts")
        expect(data["controller"]).to eq("posts")
      end
    end

    context "when the report does not exist" do
      it "returns 200 HTML with a not-found message" do
        get "/rails/memory/reports/nonexistent"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Report not found")
      end

      it "returns 404 JSON" do
        get "/rails/memory/reports/nonexistent", headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(:not_found)
      end
    end

    it "returns 403 when dashboard is disabled" do
      RailsMemoryProfiler.config.dashboard_enabled = false
      get "/rails/memory/reports/any"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /rails/memory/reports/compare" do
    context "with two valid report ids" do
      let(:id_a) do
        RailsMemoryProfiler::ReportStore.push(report.merge(path: "/posts"))
        RailsMemoryProfiler::ReportStore.all.last[:id]
      end
      let(:id_b) do
        RailsMemoryProfiler::ReportStore.push(report.merge(path: "/users", allocated_objects: 20_000))
        RailsMemoryProfiler::ReportStore.all.last[:id]
      end

      it "returns 200 HTML" do
        get "/rails/memory/reports/compare?ids[]=#{id_a}&ids[]=#{id_b}"
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("text/html")
      end

      it "returns 200 JSON with left and right reports" do
        get "/rails/memory/reports/compare?ids[]=#{id_a}&ids[]=#{id_b}",
            headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data["left"]["path"]).to eq("/posts")
        expect(data["right"]["path"]).to eq("/users")
      end
    end

    context "with fewer than two valid ids" do
      it "redirects to reports index when ids are missing" do
        get "/rails/memory/reports/compare"
        expect(response).to redirect_to("/rails/memory/reports")
      end

      it "redirects when only one valid id is given" do
        RailsMemoryProfiler::ReportStore.push(report)
        id = RailsMemoryProfiler::ReportStore.all.first[:id]
        get "/rails/memory/reports/compare?ids[]=#{id}&ids[]=nonexistent"
        expect(response).to redirect_to("/rails/memory/reports")
      end
    end

    it "returns 403 when dashboard is disabled" do
      RailsMemoryProfiler.config.dashboard_enabled = false
      get "/rails/memory/reports/compare"
      expect(response).to have_http_status(:forbidden)
    end
  end
end