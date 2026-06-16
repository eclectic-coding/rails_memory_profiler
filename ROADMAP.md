# ROADMAP

## Problem

The [`memory_profiler`](https://github.com/SamSaffron/memory_profiler) gem is the de-facto standard for understanding Ruby object allocations, but its output is terminal-only and scoped to a block you wrap manually. In a Rails app there's no easy way to see _which requests_ allocate the most, drill into the breakdown, or compare across a session. This gem fills that gap: zero-config middleware captures allocations per request and serves them in a mountable dashboard UI.

---

## 0.1.0 — Usable

> Goal: a developer can add the gem, mount the engine, and immediately see per-request allocation data without any other setup.

**Core**
- `Configuration` — `enabled`, `sample_rate` (every N requests), `store_size`, `dashboard_enabled`, `min_allocated_objects` threshold, `ignore_paths`, `ignore_controllers`
- `Middleware` — wraps each request; uses `GC.stat` diff for lightweight per-request totals; captures `allocated_objects`, `allocated_bytes`, `retained_objects`, `retained_bytes`
- `ReportStore` — thread-safe circular buffer (same pattern as QueryOwl `EventStore`); stores per-request reports up to `store_size`
- `RequestContext` — captures `controller`, `action`, `path`, `duration_ms` alongside allocation data
- `Engine` — `isolate_namespace`, importmap + Turbo wiring, middleware registration

**Dashboard UI**
- `ReportsController < ActionController::Base` — `index` (HTML + JSON), `show` (per-request drilldown)
- Layout — standalone `app/views/layouts/rails_memory_profiler/application.html.erb` with `inline_styles` helper and importmap tags (matches QueryOwl pattern)
- Index view — sortable table: path, controller#action, allocated objects, allocated bytes, retained objects, timestamp
- Show view — full `MemoryProfiler.report` breakdown for that request: top allocating lines, top allocating gems, top allocating classes
- Stimulus controller — client-side filter by controller name
- Inline CSS via `_*.css` partials in `app/assets/stylesheets/rails_memory_profiler/` (no asset pipeline dependency)
- `check_dashboard_enabled` guard — returns `403` unless `config.dashboard_enabled`

**Developer experience**
- `rails generate rails_memory_profiler:install` — copies `config/initializers/rails_memory_profiler.rb` with all options documented
- Routes: `mount RailsMemoryProfiler::Engine, at: "/rails/memory"`
- README — installation, mount, configuration table, screenshot

**Gem hygiene**
- `required_ruby_version >= 3.3`
- Add `memory_profiler`, `importmap-rails`, `turbo-rails` as dependencies
- Fill gemspec `homepage`, `summary`, `description`, `source_code_uri`, `changelog_uri`
- Remove `allowed_push_host` TODO guard to enable RubyGems publish

---

## 0.2.0 — Richer reports

- Full `MemoryProfiler.report` stored per request (opt-in via `config.detailed_reports = true`; has overhead — default: sample every 10th request)
- Drilldown view with allocation breakdown by gem, file, class, and line
- Configurable `min_allocated_objects` — skip recording requests below the threshold (reduces noise)
- Sort + filter by allocated bytes, retained objects, controller, action
- Request comparison: pin two requests and diff their allocation profiles

---

## 0.3.0 — Workflow integration

- Notifiers — same pluggable interface as QueryOwl: `Notifiers::Logger`, `Notifiers::Stdout`, `Notifiers::Console` (with colorized output)
- File logger — append JSON-serialized reports to a configurable path
- `TestHelper` — `capture_allocations { }`, `assert_allocations_below(n)`, RSpec matchers (`allocate_fewer_than`)
- `config.raise_on_allocation_spike` — raise in test env when a request exceeds a threshold

---

## 1.0.0 — Stable API

- Public API surface locked: `Configuration`, `Middleware`, `ReportStore`, `TestHelper`
- Thread safety audit across all `Thread.current` usage
- `ActiveSupport::Deprecation` infrastructure for future breaking changes
- Full YARD documentation on public classes
- Compatibility matrix finalized (Rails 7.1 / 8.x, Ruby 3.3 / 3.4 / 4.0)

---

Have a feature request or found a bug? [Open an issue](https://github.com/eclectic-coding/rails_memory_profiler/issues) — see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.