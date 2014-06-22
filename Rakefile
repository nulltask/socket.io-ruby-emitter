require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

namespace :npm do
  desc "npm package install for testing"
  task :install do
    dir = File.join(File.expand_path("..", __FILE__), "spec")
    sh "cd '#{dir}' && npm install"
  end
end

task :spec_with_npm_install => ["npm:install", "spec"]

task :default => :spec_with_npm_install

