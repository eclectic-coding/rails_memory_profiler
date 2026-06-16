# RailsMemoryProfiler

[![CI](https://github.com/eclectic-coding/rails_memory_profiler/actions/workflows/main.yml/badge.svg)](https://github.com/eclectic-coding/rails_memory_profiler/actions/workflows/main.yml)
[![Gem Version](https://img.shields.io/gem/v/rails_memory_profiler)](https://rubygems.org/gems/rails_memory_profiler)
[![Gem Downloads](https://img.shields.io/gem/dt/rails_memory_profiler)](https://rubygems.org/gems/rails_memory_profiler)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.3-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org)
[![Rails](https://img.shields.io/badge/rails-%3E%3D%207.1-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org)
[![codecov](https://codecov.io/gh/eclectic-coding/rails_memory_profiler/branch/main/graph/badge.svg)](https://codecov.io/gh/eclectic-coding/rails_memory_profiler)

Per-request memory allocation reports with a mountable dashboard UI. Fills the gap between the [`memory_profiler`](https://github.com/SamSaffron/memory_profiler) gem (terminal-only output, manual block wrapping) and having nowhere useful to browse results in a Rails app.

A Rack middleware captures object allocations for every request using `GC.stat` diffs. Results are stored in a thread-safe ring buffer and served through a mountable engine with a sortable, filterable dashboard.

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

## Dashboard

The index view shows a sortable table of captured requests. Click any row to open the detail view for that request.

Columns: **Path**, **Controller#Action**, **Allocated Objects** (colour-coded), **Retained Objects**, **Duration (ms)**, **Recorded At**.

Use the controller filter to narrow the table down to a specific controller without a page reload.

## Configuration

All options and their defaults:

| Option | Default | Description |
|---|---|---|
| `enabled` | `true` in development | Enable/disable request profiling |
| `sample_rate` | `1` | Profile every Nth request (`1` = every request) |
| `store_size` | `100` | Max reports in the ring buffer; oldest are evicted when full |
| `dashboard_enabled` | `true` in development | Enable the dashboard endpoint |
| `min_allocated_objects` | `0` | Skip requests that allocate fewer objects than this |
| `ignore_paths` | `[]` | Paths to skip — strings (prefix) or regexes |
| `ignore_controllers` | `[]` | Controller names to skip (e.g. `"rails/health"`) |

Example:

```ruby
RailsMemoryProfiler.configure do |config|
  config.sample_rate        = 5
  config.min_allocated_objects = 1_000
  config.ignore_paths       = ["/rails/memory", "/up"]
  config.ignore_controllers = ["rails/health"]
end
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/eclectic-coding/rails_memory_profiler).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).