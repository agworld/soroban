# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "soroban"
  gem.homepage = "https://github.com/agworld/soroban"
  gem.license = "MIT"
  gem.summary = "Soroban is a calculating engine that understands Excel formulas."
  gem.description = "Soroban makes it easy to extract and execute formulas from Excel spreadsheets. It rewrites Excel formulas as Ruby expressions, and allows you to bind named variables to spreadsheet cells to easily manipulate inputs and capture outputs."
  gem.email = "jason.hutchens@agworld.com.au"
  gem.authors = ["Jason Hutchens"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = false
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
