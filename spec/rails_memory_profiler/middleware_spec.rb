require "rails_helper"

RSpec.describe RailsMemoryProfiler::Middleware do
  let(:inner_app) { ->(_env) { [200, {}, ["OK"]] } }
  let(:middleware) { described_class.new(inner_app) }

  def env_for(path = "/test", params: {})
    env = Rack::MockRequest.env_for(path)
    env["action_dispatch.request.path_parameters"] = params
    env
  end

  before do
    RailsMemoryProfiler.reset_config!
    RailsMemoryProfiler.config.enabled = true
    RailsMemoryProfiler::ReportStore.clear
  end

  after { RailsMemoryProfiler::ReportStore.clear }

  describe "#call" do
    it "passes the response through unchanged" do
      status, headers, body = middleware.call(env_for)

      expect(status).to eq(200)
      expect(body).to eq(["OK"])
    end

    it "records a report for each request" do
      middleware.call(env_for("/posts", params: { controller: "posts", action: "index" }))

      expect(RailsMemoryProfiler::ReportStore.size).to eq(1)
      report = RailsMemoryProfiler::ReportStore.all.first
      expect(report[:path]).to eq("/posts")
      expect(report[:controller]).to eq("posts")
      expect(report[:action]).to eq("index")
      expect(report[:allocated_objects]).to be_a(Integer)
      expect(report[:retained_objects]).to be >= 0
      expect(report[:duration_ms]).to be_a(Float)
    end

    context "when disabled" do
      it "skips profiling" do
        RailsMemoryProfiler.config.enabled = false
        middleware.call(env_for)

        expect(RailsMemoryProfiler::ReportStore.size).to eq(0)
      end
    end

    context "with ignore_paths" do
      it "skips requests matching a string prefix" do
        RailsMemoryProfiler.config.ignore_paths = ["/health"]
        middleware.call(env_for("/health"))

        expect(RailsMemoryProfiler::ReportStore.size).to eq(0)
      end

      it "skips requests matching a regexp" do
        RailsMemoryProfiler.config.ignore_paths = [/\A\/rails/]
        middleware.call(env_for("/rails/memory"))

        expect(RailsMemoryProfiler::ReportStore.size).to eq(0)
      end

      it "still profiles non-matching paths" do
        RailsMemoryProfiler.config.ignore_paths = ["/health"]
        middleware.call(env_for("/posts"))

        expect(RailsMemoryProfiler::ReportStore.size).to eq(1)
      end
    end

    context "with ignore_controllers" do
      it "skips requests from an ignored controller" do
        RailsMemoryProfiler.config.ignore_controllers = ["rails_memory_profiler/reports"]
        env = env_for("/rails/memory", params: { controller: "rails_memory_profiler/reports" })
        middleware.call(env)

        expect(RailsMemoryProfiler::ReportStore.size).to eq(0)
      end
    end

    context "with min_allocated_objects" do
      it "skips reports below the threshold" do
        RailsMemoryProfiler.config.min_allocated_objects = 999_999_999
        middleware.call(env_for)

        expect(RailsMemoryProfiler::ReportStore.size).to eq(0)
      end
    end

    context "with sample_rate" do
      it "only profiles every Nth request" do
        RailsMemoryProfiler.config.sample_rate = 3

        5.times { middleware.call(env_for) }

        expect(RailsMemoryProfiler::ReportStore.size).to eq(1)
      end
    end
  end
end