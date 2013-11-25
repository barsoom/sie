require "bundler/gem_tasks"

namespace :spec do
  task :unit do
    puts "Running unit tests:"
    system("rspec spec/unit/**_spec.rb") || exit(1)
  end

  task :integration do
    puts "Running integrated tests:"
    system("rspec spec/integration/**_spec.rb") || exit(1)
  end
end

task :default => [ :"spec:unit", :"spec:integration" ]
