# ROADMAP

## Problem

The [`memory_profiler`](https://github.com/SamSaffron/memory_profiler) gem is the de-facto standard for understanding Ruby object allocations, but its output is terminal-only and scoped to a block you wrap manually. In a Rails app there's no easy way to see _which requests_ allocate the most, drill into the breakdown, or compare across a session. This gem fills that gap: zero-config middleware captures allocations per request and serves them in a mountable dashboard UI.

---

## 0.4.0 — Housekeeping

- Remove unused engine boilerplate that ships in the gem: `ApplicationController` (dashboard uses `BaseController`), `ApplicationJob`, `ApplicationMailer`, `ApplicationRecord`, and the empty rake tasks stub
- Fix no-op ternary in `comparisons/show.html.erb` — `lv.is_a?(Float) ? lv : lv` always returns `lv`; Float branch should call `.round(2)`
- Resolve `RequestContext` — it is defined and exported but never called (middleware reads from `env` directly); either remove it or wire it up as a documented concern for host-app controllers
- Minitest integration — `assert_allocations_below` currently raises a plain `RuntimeError`; when Minitest is loaded it should raise `Minitest::Assertion` so failures are reported as failures, not errors; add a `minitest_matchers.rb` file parallel to `rspec_matchers.rb`

---

## 0.5.0 — Polish

- Auto-ignore the engine's own mount path — dashboard requests are currently profiled and stored, creating noise; detect the mount point and add it to `ignore_paths` automatically (or add it as the default in the generator template)
- `ReportStore.clear` via the dashboard — add a UI button to flush the in-memory ring buffer without restarting the server

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
