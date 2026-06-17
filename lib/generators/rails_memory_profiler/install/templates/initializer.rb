RailsMemoryProfiler.configure do |config|
  # Enable or disable per-request memory profiling.
  # Defaults to true in development, false elsewhere.
  # config.enabled = Rails.env.development?

  # Profile every Nth request. 1 = every request, 10 = every 10th, etc.
  # Increase for busier apps where profiling every request adds too much overhead.
  # config.sample_rate = 1

  # Maximum number of reports kept in the in-memory ring buffer.
  # Oldest reports are evicted when the buffer is full.
  # config.store_size = 100

  # Enable the HTML/JSON dashboard at /reports (relative to the engine mount point).
  # Defaults to true in development, false elsewhere.
  # config.dashboard_enabled = Rails.env.development?

  # Skip recording requests that allocate fewer objects than this threshold.
  # Useful for filtering out trivial requests (health checks, asset hits, etc.).
  # config.min_allocated_objects = 0

  # Paths to skip entirely — accepts strings (prefix match) or regexes.
  # The engine's own mount path is a good candidate to add here.
  # config.ignore_paths = ["/rails/memory", "/up", %r{^/assets/}]

  # Controllers to skip — matched against the Rails controller name.
  # config.ignore_controllers = ["rails/health", "rails_memory_profiler/reports"]

  # Capture full MemoryProfiler.report breakdowns (by gem, class, file, location).
  # Requires `gem "memory_profiler"` in your Gemfile. Has significant overhead — use with sampling.
  # config.detailed_reports = false

  # When detailed_reports is enabled, capture a full report every Nth profiled request.
  # config.detailed_sample_rate = 10
end
