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

    context "with raise_on_allocation_spike" do
      it "raises AllocationSpikeError when allocated objects exceed the threshold" do
        RailsMemoryProfiler.config.raise_on_allocation_spike = 1
        expect { middleware.call(env_for) }.to raise_error(RailsMemoryProfiler::AllocationSpikeError, /threshold: 1/)
      end

      it "does not raise when allocations are below the threshold" do
        RailsMemoryProfiler.config.raise_on_allocation_spike = 999_999_999
        expect { middleware.call(env_for) }.not_to raise_error
      end
    end

    context "with sample_rate" do
      it "only profiles every Nth request" do
        RailsMemoryProfiler.config.sample_rate = 3

        5.times { middleware.call(env_for) }

        expect(RailsMemoryProfiler::ReportStore.size).to eq(1)
      end
    end

    context "with detailed_reports" do
      before do
        RailsMemoryProfiler.config.detailed_reports     = true
        RailsMemoryProfiler.config.detailed_sample_rate = 1
      end

      it "stores allocated and retained object counts" do
        middleware.call(env_for)

        report = RailsMemoryProfiler::ReportStore.all.first
        expect(report[:allocated_objects]).to be_a(Integer)
        expect(report[:retained_objects]).to be >= 0
      end

      it "stores a detail hash with breakdown arrays keyed by category" do
        middleware.call(env_for)

        detail = RailsMemoryProfiler::ReportStore.all.first[:detail]
        expect(detail).to be_a(Hash)
        %i[allocated_by_gem allocated_by_file allocated_by_class allocated_by_location
           retained_by_gem retained_by_file retained_by_class retained_by_location].each do |key|
          expect(detail).to have_key(key)
          expect(detail[key]).to be_an(Array)
        end
      end

      it "serializes each breakdown entry as {name:, count:}" do
        middleware.call(env_for)

        detail = RailsMemoryProfiler::ReportStore.all.first[:detail]
        nonempty = detail.values.find(&:any?)
        expect(nonempty.first).to include(:name, :count)
      end

      it "does not include detail on basic (non-detailed) reports" do
        RailsMemoryProfiler.config.detailed_reports = false
        middleware.call(env_for)

        report = RailsMemoryProfiler::ReportStore.all.first
        expect(report).not_to have_key(:detail)
      end

      it "raises a helpful LoadError when memory_profiler is not installed" do
        allow(middleware).to receive(:require).with("memory_profiler").and_raise(LoadError)

        expect { middleware.send(:require_memory_profiler!) }.to raise_error(
          LoadError, /Add `gem 'memory_profiler'`/
        )
      end

      context "with detailed_sample_rate" do
        it "only captures detailed reports every Nth profiled request" do
          RailsMemoryProfiler.config.detailed_sample_rate = 3

          5.times { middleware.call(env_for) }

          reports = RailsMemoryProfiler::ReportStore.all
          expect(reports.count { |r| r.key?(:detail) }).to eq(1)
          expect(reports.count { |r| !r.key?(:detail) }).to eq(4)
        end
      end
    end
  end
end