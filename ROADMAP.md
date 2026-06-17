# ROADMAP

## Problem

The [`memory_profiler`](https://github.com/SamSaffron/memory_profiler) gem is the de-facto standard for understanding Ruby object allocations, but its output is terminal-only and scoped to a block you wrap manually. In a Rails app there's no easy way to see _which requests_ allocate the most, drill into the breakdown, or compare across a session. This gem fills that gap: zero-config middleware captures allocations per request and serves them in a mountable dashboard UI.

---

## Status

All planned milestones (0.1.0 through 1.0.0) have shipped. There are no further planned milestones at this time.

The gem is considered stable. The public API — `Configuration`, `Middleware`, `ReportStore`, `TestHelper`, and the notifier interface — will not have breaking changes without a deprecation notice via `RailsMemoryProfiler.deprecator`.

---

Have a feature request or found a bug? [Open an issue](https://github.com/eclectic-coding/rails_memory_profiler/issues) — see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
