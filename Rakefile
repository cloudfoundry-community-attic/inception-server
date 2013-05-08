ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __FILE__)

require "rubygems"
require "bundler"
Bundler.setup(:default, :test, :development, :integration)

require "bundler/gem_tasks"

require "rake/dsl_definition"
require "rake"
require "rspec/core/rake_task"


begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
rescue LoadError
  puts ">>>>> Kitchen gem not loaded, omitting tasks" unless ENV['CI']
end


if defined?(RSpec)
  namespace :spec do
    desc "Run Unit Tests"
    unit_rspec_task = RSpec::Core::RakeTask.new(:unit) do |t|
      t.pattern = "spec/unit/**/*_spec.rb"
      t.rspec_opts = %w(--format progress --color)
    end

    desc "Run cookbook tests (only if $AWS_ACCESS_KEY_ID is set)"
    task :cookbooks do
      if ENV['AWS_ACCESS_KEY_ID']
        sh "kitchen test ec2"
      else
        puts "Skipping spec:cookbooks. Please provide $AWS_ACCESS_KEY_ID & $AWS_SECRET_ACCESS_KEY_ID"
      end
    end

    namespace :integration do
      namespace :aws do
        jobs = Dir["spec/integration/aws/*_spec.rb"].map {|f| File.basename(f).gsub(/aws_(.*)_spec.rb/, '\1')}
        jobs.each do |job|
          desc "Run AWS '#{job}' Integration Test"
          RSpec::Core::RakeTask.new(job.to_sym) do |t|
            t.pattern = "spec/integration/aws/aws_#{job}_spec.rb"
            t.rspec_opts = %w(--format progress --color)
          end
        end
      end

      desc "Run AWS Integration Tests"
      RSpec::Core::RakeTask.new(:aws) do |t|
        t.pattern = "spec/integration/aws/*_spec.rb"
        t.rspec_opts = %w(--format progress --color)
      end
    end

    desc "Run all Integration Tests"
    task :integration => %w[spec:integration:aws]
  end

  desc "Install dependencies and run tests"
  task :spec => %w(spec:unit spec:integration)
end

task :default => ["spec:unit"]