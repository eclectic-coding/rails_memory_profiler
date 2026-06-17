# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Auto-ignore dashboard mount path — `Engine.mount_path` lazily detects where the engine is mounted and the middleware skips those requests automatically; no configuration needed
- `DELETE /reports/clear` — flushes the in-memory ring buffer without a server restart; "Clear All" button appears in the dashboard header when reports are present (guarded by a confirm dialog)

## [0.4.0] - 2026-06-17

### Added
- Minitest integration (`require "rails_memory_profiler/minitest_matchers"`) — auto-includes `assert_allocates_fewer_than(n, msg = nil) { }` into `Minitest::Test`; opt-in, not auto-required

### Changed
- `assert_allocations_below` now raises `Minitest::Assertion` when Minitest is loaded (was plain `RuntimeError`), so failures are reported as failures rather than errors in Minitest suites

### Removed
- `RequestContext` — module was defined but never called (middleware always read from `env` directly); removed to reduce the public API surface before 1.0.0
- Unused engine boilerplate (`ApplicationController`, `ApplicationJob`, `ApplicationMailer`, `ApplicationRecord`, empty rake tasks stub) — these files shipped in the gem but served no purpose

### Fixed
- No-op ternary in comparison view — `lv.is_a?(Float) ? lv : lv` now correctly calls `.round(2)` on the Float branch

## [0.3.0] - 2026-06-17

### Added
- `TestHelper` module (`require "rails_memory_profiler/test_helper"`) — `capture_allocations { }` returns allocated object count via GC.stat diff; `assert_allocations_below(n) { }` raises with a descriptive message if count exceeds threshold; `extend self` so methods work as module-level calls or as instance methods when included in a test class
- RSpec matcher (`require "rails_memory_profiler/rspec_matchers"`) — `expect { }.to allocate_fewer_than(n)` block expectation backed by `TestHelper.capture_allocations`; both files are opt-in and not auto-required
- `config.raise_on_allocation_spike` (default: `nil`) — set to an integer; middleware raises `AllocationSpikeError` after recording a report whose `allocated_objects` exceeds the threshold; `AllocationSpikeError < StandardError` defined at the module level
- `config.notifiers` (default: `[]`) — array of objects responding to `#call(report)`; dispatched from middleware after each report is stored; built-in notifiers: `Notifiers::Logger` (Rails.logger.info), `Notifiers::Stdout` ($stdout.puts), `Notifiers::Console` (colorized ANSI: green < 5k, yellow < 20k, red ≥ 20k alloc), `Notifiers::FileLogger` (JSON lines appended to a path)
- `config.log_file` (default: `nil`) — convenience shortcut; when set, middleware auto-creates a `Notifiers::FileLogger` per request and appends to the given path (JSON lines, ISO 8601 timestamps)

## [0.2.0] - 2026-06-17

### Added
- `config.detailed_reports` — opt-in full `MemoryProfiler.report` capture per request (default: `false`); requires `gem "memory_profiler"` in the host app's Gemfile (soft dependency — not declared in gemspec)
- `config.detailed_sample_rate` — capture a detailed report every Nth profiled request when `detailed_reports` is enabled (default: `10`)
- Show view drilldown — when a report includes detail, the show page renders breakdown tables (allocated/retained by gem, class, file, and location); top 20 entries per table
- `_06_breakdowns.css` — responsive grid layout for breakdown tables
- Filter bar: action text filter and HTTP method select alongside the existing controller filter; all three applied as AND logic client-side; per-input floating ✕ clear buttons and a global Reset button
- Request comparison: select any two reports via checkboxes; a compare bar appears with a direct link to `GET /comparison?ids[]=…&ids[]=…`; `ComparisonsController#show` renders a side-by-side table with delta column (green = better, red = worse for memory/duration metrics)
- `BaseController` — shared dashboard setup (layout, helper, CSRF, dashboard guard) extracted from `ReportsController`; `ComparisonsController` inherits from it
- Stimulus controllers moved to `controllers/` subfolder; `controllers/application.js` + `controllers/index.js` follow the stimulus-rails convention

### Fixed
- Standardised recommended engine mount path to `/rails/memory` across generator output, README, and dummy app (`/rails_memory_profiler` was the old default)
- Moved `puma`, `sqlite3`, and `propshaft` to `:development, :test` Gemfile group so the dummy app can be run manually without JS asset routing errors
- Fixed scope bug: `data-controller="filter"` was on `.rmp-filters` so `data-filter-target="row"` elements in the table were invisible to the controller; outer wrapper now carries both `filter` and `compare` controllers
- Fixed `_06_breakdowns.css` using undefined `--rmp-*` CSS variables; updated to `--surface`, `--border`, `--muted` defined in `_01_base.css`

## [0.1.0] - 2026-06-16

### Added
- `Configuration` — `enabled`, `sample_rate`, `store_size`, `dashboard_enabled`, `min_allocated_objects`, `ignore_paths`, `ignore_controllers`
- `Middleware` — wraps each request; uses `GC.stat` diff to capture `allocated_objects` and `retained_objects` per request; supports path/controller ignoring and request sampling
- `ReportStore` — thread-safe circular buffer storing per-request reports up to `store_size`; each report is assigned a unique hex id on push; `ReportStore.find(id)` for per-report lookup
- `RequestContext` — Thread.current-scoped storage for request metadata (`controller`, `action`, `path`, `method`)
- `Engine` — registers middleware; wires importmap and assets initializers for Stimulus + Turbo
- `ReportsController` — mountable dashboard with `index` (HTML + JSON) and `show` (HTML + JSON); guarded by `config.dashboard_enabled`
- Standalone layout with inlined CSS and importmap tags; no asset pipeline dependency
- Index view — sortable table (path, controller#action, allocated, retained, duration, timestamp) with colour-coded allocation badges
- Show view — per-request detail grid for all stored report fields
- `ApplicationHelper` — `inline_styles`, `sort_th`, `allocation_badge`
- Stimulus `filter_controller` — client-side controller-name filter with clear button
- Five CSS partials in `app/assets/stylesheets/rails_memory_profiler/`
- `rails generate rails_memory_profiler:install` — creates `config/initializers/rails_memory_profiler.rb` with all options documented and prints mount instructions
- README rewritten with installation, mount, configuration table, and dashboard description
- Gemspec: `homepage`, `summary`, `description`, `source_code_uri`, `changelog_uri` filled in; `required_ruby_version >= 3.3` set; `importmap-rails` and `turbo-rails` added as runtime dependencies; `allowed_push_host` guard removed

[Unreleased]: https://github.com/eclectic-coding/rails_memory_profiler/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/eclectic-coding/rails_memory_profiler/releases/tag/v0.4.0
[0.3.0]: https://github.com/eclectic-coding/rails_memory_profiler/releases/tag/v0.3.0
[0.2.0]: https://github.com/eclectic-coding/rails_memory_profiler/releases/tag/v0.2.0
[0.1.0]: https://github.com/eclectic-coding/rails_memory_profiler/releases/tag/v0.1.0
