# ROADMAP

## Problem

The [`memory_profiler`](https://github.com/SamSaffron/memory_profiler) gem is the de-facto standard for understanding Ruby object allocations, but its output is terminal-only and scoped to a block you wrap manually. In a Rails app there's no easy way to see _which requests_ allocate the most, drill into the breakdown, or compare across a session. This gem fills that gap: zero-config middleware captures allocations per request and serves them in a mountable dashboard UI.

---

Have a feature request or found a bug? [Open an issue](https://github.com/eclectic-coding/rails_memory_profiler/issues) — see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
