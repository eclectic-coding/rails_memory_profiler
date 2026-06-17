# ROADMAP

## Problem

The [`memory_profiler`](https://github.com/SamSaffron/memory_profiler) gem is the de-facto standard for understanding Ruby object allocations, but its output is terminal-only and scoped to a block you wrap manually. In a Rails app there's no easy way to see _which requests_ allocate the most, drill into the breakdown, or compare across a session. This gem fills that gap: zero-config middleware captures allocations per request and serves them in a mountable dashboard UI.

---


## 0.2.0 — Richer reports

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
- Documentation audit: review and finalize README, add `CONTRIBUTING.md`, update ROADMAP to reflect no future planned milestones with links for bug reports, feature requests, and contribution guidelines

---

Have a feature request or found a bug? [Open an issue](https://github.com/eclectic-coding/rails_memory_profiler/issues) — see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
