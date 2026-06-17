# Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/eclectic-coding/rails_memory_profiler).

## Getting started

```bash
git clone https://github.com/eclectic-coding/rails_memory_profiler.git
cd rails_memory_profiler
bundle install
bundle exec rake          # lint → security audit → specs
```

## Workflow

All feature work lives on `feature/<version>-<scope>` branches (e.g. `feature/1.1.0-export`). Every branch produces two commits before opening a PR:

1. **Feature commit** — implementation + specs. Run `bundle exec rake` and fix all failures before committing.
2. **Docs commit** — add shipped items to `CHANGELOG.md` under `[Unreleased]`, remove them from `ROADMAP.md`, update `README.md` where relevant.

## Running tests

```bash
bundle exec rspec                                            # full suite
bundle exec rspec spec/rails_memory_profiler/middleware_spec.rb      # single file
bundle exec rspec spec/rails_memory_profiler/middleware_spec.rb:42   # single example
```

SimpleCov tracks coverage — the target is 100% line coverage.

## Code style

RuboCop is enforced via `rubocop-rails-omakase`. Run `bundle exec rubocop --autocorrect` to fix correctable offenses before committing.

## Reporting bugs

Open an issue at <https://github.com/eclectic-coding/rails_memory_profiler/issues> with:
- Ruby and Rails versions
- Gem version
- A minimal reproduction (initializer config + request that triggers the problem)

## Releasing (maintainers only)

```bash
bin/release <version>   # e.g. bin/release 1.1.0
```

This bumps the version, promotes `[Unreleased]` in CHANGELOG, tags, and pushes. CI picks up the tag and publishes to RubyGems automatically.