# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `config.detailed_reports` — opt-in full `MemoryProfiler.report` capture per request (default: `false`); requires `gem "memory_profiler"` in the host app's Gemfile (soft dependency — not declared in gemspec)
- `config.detailed_sample_rate` — capture a detailed report every Nth profiled request when `detailed_reports` is enabled (default: `10`)
- Show view drilldown — when a report includes detail, the show page renders breakdown tables (allocated/retained by gem, class, file, and location); top 20 entries per table
- `_06_breakdowns.css` — responsive grid layout for breakdown tables

### Fixed
- Standardised recommended engine mount path to `/rails/memory` across generator output, README, and dummy app (`/rails_memory_profiler` was the old default)
- Moved `puma`, `sqlite3`, and `propshaft` to `:development, :test` Gemfile group so the dummy app can be run manually without JS asset routing errors

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

[Unreleased]: https://github.com/eclectic-coding/rails_memory_profiler/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/eclectic-coding/rails_memory_profiler/releases/tag/v0.1.0
