source "https://rubygems.org"

# Specify your gem's dependencies in rails_memory_profiler.gemspec.
gemspec

gem "puma"
gem "sqlite3"
gem "propshaft"
gem "importmap-rails"
gem "turbo-rails"

# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
gem "rubocop-rails-omakase", require: false

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
gem "bundler-audit"

group :test do
  gem "rspec-rails"
  gem "simplecov", require: false
  gem "simplecov_json_formatter", require: false
end
