require "bundler/gem_tasks"

begin
  require "rspec/core/rake_task"

  desc "Run unit tests."
  RSpec::Core::RakeTask.new(:unit_tests) do |t|
    t.pattern = "spec/unit/**/*.rb"
  end

  desc "Run integration tests."
  RSpec::Core::RakeTask.new(:integration_tests) do |t|
    t.pattern = "spec/integration/**/*.rb"
  end

  desc "Run all tests."
  task default: [ :unit_tests, :integration_tests ]
rescue LoadError
  warn "RSpec not loaded. Quitting."
end

