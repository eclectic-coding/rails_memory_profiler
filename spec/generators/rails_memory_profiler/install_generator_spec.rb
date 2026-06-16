require "rails_helper"
require "generators/rails_memory_profiler/install/install_generator"

RSpec.describe RailsMemoryProfiler::Generators::InstallGenerator do
  let(:tmpdir) { Dir.mktmpdir }
  let(:initializer_path) { File.join(tmpdir, "config/initializers/rails_memory_profiler.rb") }

  before { FileUtils.mkdir_p(File.join(tmpdir, "config/initializers")) }
  after  { FileUtils.rm_rf(tmpdir) }

  it "creates the initializer file" do
    described_class.start([], destination_root: tmpdir, quiet: true)
    expect(File.exist?(initializer_path)).to be(true)
  end

  it "includes the configure block" do
    described_class.start([], destination_root: tmpdir, quiet: true)
    expect(File.read(initializer_path)).to include("RailsMemoryProfiler.configure do |config|")
  end

  it "documents all configuration options" do
    described_class.start([], destination_root: tmpdir, quiet: true)
    content = File.read(initializer_path)
    %w[enabled sample_rate store_size dashboard_enabled min_allocated_objects
       ignore_paths ignore_controllers].each do |option|
      expect(content).to include("config.#{option}")
    end
  end
end