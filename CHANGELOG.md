# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] — Core (in progress)

### Added
- `Configuration` — `enabled`, `sample_rate`, `store_size`, `dashboard_enabled`, `min_allocated_objects`, `ignore_paths`, `ignore_controllers`
- `Middleware` — wraps each request; uses `GC.stat` diff to capture `allocated_objects` and `retained_objects` per request; supports path/controller ignoring and request sampling
- `ReportStore` — thread-safe circular buffer storing per-request reports up to `store_size`
- `RequestContext` — Thread.current-scoped storage for request metadata (`controller`, `action`, `path`, `method`)
- `Engine` — registers middleware via initializer
