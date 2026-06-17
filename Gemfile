source "https://rubygems.org"

gemspec

group :development do
  gem "rubocop-rails-omakase", require: false
  gem "bundler-audit"
end

group :development, :test do
  gem "puma"
  gem "sqlite3"
  gem "propshaft"
end

group :test do
  gem "memory_profiler"
  gem "rspec-rails"
  gem "simplecov", require: false
  gem "simplecov_json_formatter", require: false
end
