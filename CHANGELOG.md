# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
