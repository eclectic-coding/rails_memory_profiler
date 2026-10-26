require "bundler/setup"

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

require "bundler/gem_tasks"

require 'rubocop/rake_task'
require 'bundler/audit/task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new(:lint)
Bundler::Audit::Task.new
RSpec::Core::RakeTask.new(:spec)

desc "Run Brakeman against the engine (dummy app excluded)"
task :brakeman do
  sh "bundle exec brakeman -q --no-pager --force-scan --skip-files spec/ " \
     "-i config/brakeman.ignore --ensure-ignore-notes ."
end

task default: [:lint, :'bundle:audit:update', 'bundle:audit:check', :brakeman, :spec]
