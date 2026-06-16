# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bundle exec rake                        # full suite: lint → security audit → specs (run before every commit)
bundle exec rspec spec/path/to_spec.rb  # single spec file
bundle exec rspec spec/rails_memory_profiler/middleware_spec.rb:42  # single example by line
bundle exec rubocop                     # lint only
bundle exec rubocop --autocorrect       # auto-fix correctable offenses
```

## Workflow

All feature work lives on `feature/<version>-<scope>` branches (e.g. `feature/0.1.0-core`). Every branch produces two commits before pushing:

1. **Feature commit** — implementation + specs. Run `bundle exec rake` and fix all failures before committing.
2. **Docs commit** — add shipped items to `CHANGELOG.md`, remove them from `ROADMAP.md`, update `README.md`. Run `bundle exec rake` again before this commit.

## Architecture

This is a Rails engine gem. The core data pipeline is entirely in `lib/`:

- **`RailsMemoryProfiler`** (`lib/rails_memory_profiler.rb`) — top-level module; exposes `.configure`, `.config`, `.reset_config!`
- **`Configuration`** — plain Ruby object holding all user-facing settings; instantiated once via `RailsMemoryProfiler.config`
- **`Middleware`** — Rack middleware registered by the `Engine` initializer; wraps each request, diffs `GC.stat` before/after to capture `allocated_objects` and `retained_objects`, then pushes a report hash into `ReportStore`
- **`ReportStore`** — thread-safe circular buffer (module with class-level state + `Mutex`); capacity is `config.store_size`
- **`RequestContext`** — thin `Thread.current` wrapper for per-request metadata; set inside `Middleware#profile` after `app.call`
- **`Engine`** — mounts the engine, registers `Middleware` via an initializer

The dashboard controller and views (issue #2) will use `ActionController::Base` (not API), with a standalone layout, inline CSS loaded via a helper that reads `_*.css` partials from `app/assets/stylesheets/rails_memory_profiler/`, and Stimulus + Turbo via importmap — the same pattern used in `query_owl` at `/Users/eclecticcoding/code/gems/query_owl`.

## Test setup

Specs load the dummy Rails app at `spec/dummy/`. Use `rails_helper` for all specs (it boots the full engine). The dummy app has `config.api_only = true`; the dashboard controller will explicitly inherit from `ActionController::Base` to work around this.

SimpleCov tracks coverage — target is 100% line coverage. The coverage report is written to `coverage/` (gitignored).

## RuboCop

Inherits `rubocop-rails-omakase`. Key enforced rules: double-quoted strings, no spaces inside array brackets. `spec/**/*` is excluded from linting.