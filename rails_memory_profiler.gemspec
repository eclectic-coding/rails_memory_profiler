require_relative "lib/rails_memory_profiler/version"

Gem::Specification.new do |spec|
  spec.name        = "rails_memory_profiler"
  spec.version     = RailsMemoryProfiler::VERSION
  spec.authors     = ["Chuck Smith"]
  spec.email       = ["eclectic-coding@users.noreply.github.com"]
  spec.homepage    = "https://github.com/eclectic-coding/rails_memory_profiler"
  spec.summary     = "Per-request memory allocation reports with a mountable dashboard UI for Rails."
  spec.description = "A Rack middleware captures object allocations per request using GC.stat diffs and stores them in a thread-safe ring buffer. Results are served through a mountable engine with a sortable, filterable dashboard — filling the gap between the memory_profiler gem and having nowhere useful to view results in a Rails app."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.3"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/eclectic-coding/rails_memory_profiler"
  spec.metadata["changelog_uri"]   = "https://github.com/eclectic-coding/rails_memory_profiler/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1"
  spec.add_dependency "importmap-rails"
  spec.add_dependency "turbo-rails"
end
