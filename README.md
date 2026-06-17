# RailsMemoryProfiler

[![CI](https://github.com/eclectic-coding/rails_memory_profiler/actions/workflows/main.yml/badge.svg)](https://github.com/eclectic-coding/rails_memory_profiler/actions/workflows/main.yml)
[![Gem Version](https://img.shields.io/gem/v/rails_memory_profiler)](https://rubygems.org/gems/rails_memory_profiler)
[![Gem Downloads](https://img.shields.io/gem/dt/rails_memory_profiler)](https://rubygems.org/gems/rails_memory_profiler)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.3-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org)
[![Rails](https://img.shields.io/badge/rails-%3E%3D%207.1-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org)
[![codecov](https://codecov.io/gh/eclectic-coding/rails_memory_profiler/branch/main/graph/badge.svg)](https://codecov.io/gh/eclectic-coding/rails_memory_profiler)

Per-request memory allocation reports with a mountable dashboard UI. Fills the gap between the [`memory_profiler`](https://github.com/SamSaffron/memory_profiler) gem (terminal-only output, manual block wrapping) and having nowhere useful to browse results in a Rails app.

A Rack middleware captures object allocations for every request using `GC.stat` diffs. Results are stored in a thread-safe ring buffer and served through a mountable engine with a sortable, filterable dashboard.

---

## Table of Contents

- [Installation](#installation)
- [Dashboard](#dashboard)
- [Configuration](#configuration)
- [Compatibility](#compatibility)
- [Contributing](#contributing)
- [License](#license)

---

## Installation

Add to your Gemfile:

```ruby
gem "rails_memory_profiler", group: :development
```

Run the install generator:

```bash
bundle exec rails generate rails_memory_profiler:install
```

This creates `config/initializers/rails_memory_profiler.rb` with all options documented and prints mount instructions.

Mount the dashboard in `config/routes.rb`:

```ruby
mount RailsMemoryProfiler::Engine, at: "/rails/memory"
```

Then visit `/rails/memory/reports` to see per-request allocation data.

[↑ Back to top](#railsmemoryprofiler)

---

## Dashboard

The index view shows a sortable table of captured requests. Click any row to open the detail view for that request.

Columns: **Path**, **Controller#Action**, **Allocated Objects** (colour-coded), **Retained Objects**, **Duration (ms)**, **Recorded At**.

Use the controller filter to narrow the table down to a specific controller without a page reload.

[↑ Back to top](#railsmemoryprofiler)

---

## Configuration

All options and their defaults:

| Option | Default | Description |
|---|---|---|
| `enabled` | `true` in development | Enable/disable request profiling |
| `sample_rate` | `1` | Profile every Nth request (`1` = every request) |
| `store_size` | `100` | Max reports in the ring buffer; oldest are evicted when full |
| `dashboard_enabled` | `true` in development | Enable the dashboard endpoint |
| `min_allocated_objects` | `0` | Skip requests that allocate fewer objects than this |
| `ignore_paths` | `[]` | Additional paths to skip — strings (prefix) or regexes (the dashboard's own mount path is auto-ignored) |
| `ignore_controllers` | `[]` | Controller names to skip (e.g. `"rails/health"`) |
| `detailed_reports` | `false` | Capture full `MemoryProfiler.report` breakdowns; requires `gem "memory_profiler"` in your Gemfile |
| `detailed_sample_rate` | `10` | When `detailed_reports` is enabled, capture a full report every Nth profiled request |
| `notifiers` | `[]` | Array of objects responding to `#call(report)`; called after each report is stored |
| `log_file` | `nil` | Path to append JSON-serialized reports (one per line); shortcut for `Notifiers::FileLogger` |
| `raise_on_allocation_spike` | `nil` | Raise `AllocationSpikeError` when `allocated_objects` exceeds this threshold |

Example:

```ruby
RailsMemoryProfiler.configure do |config|
  config.sample_rate           = 5
  config.min_allocated_objects = 1_000
  config.ignore_paths          = ["/up"]   # dashboard mount path is auto-ignored
  config.ignore_controllers    = ["rails/health"]
  config.notifiers             = [RailsMemoryProfiler::Notifiers::Console.new]
  config.log_file              = Rails.root.join("log/memory_profiler.jsonl")
end
```

### Test helpers

```ruby
# Plain Ruby / shared utility
require "rails_memory_profiler/test_helper"

count = RailsMemoryProfiler::TestHelper.capture_allocations { MyClass.new }
RailsMemoryProfiler::TestHelper.assert_allocations_below(500) { MyClass.new }
# raises Minitest::Assertion when Minitest is loaded, RuntimeError otherwise

# Minitest — adds assert_allocates_fewer_than to all Minitest::Test subclasses
require "rails_memory_profiler/minitest_matchers"

assert_allocates_fewer_than(500) { MyClass.new }
assert_allocates_fewer_than(500, "MyClass allocates too much") { MyClass.new }

# RSpec
require "rails_memory_profiler/rspec_matchers"

expect { MyClass.new }.to allocate_fewer_than(500)
```

[↑ Back to top](#railsmemoryprofiler)

---

## Compatibility

|          | Ruby 3.3 | Ruby 3.4 | Ruby 4.0 |
|----------|:--------:|:--------:|:--------:|
| Rails 7.1 | ✓ | ✓ | ✓ |
| Rails 8.x | ✓ | ✓ | ✓ |

[↑ Back to top](#railsmemoryprofiler)

---

## Contributing

Bug reports and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

[↑ Back to top](#railsmemoryprofiler)

---

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[↑ Back to top](#railsmemoryprofiler)