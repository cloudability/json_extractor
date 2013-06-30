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
  gem.name = "json_extractor"
  gem.homepage = "http://github.com/bradhe/json_extractor"
  gem.license = "MIT"
  gem.summary = %Q{Tools for extracting JSON without having to deserialize it.}
  gem.description = %Q{A set of C extensions that can extract specific keys from a JSON document. Right now, only supports extracting objects.}
  gem.extensions = %w(ext/json_extractor/extconf.rb)
  gem.email = "brad@cloudability.com"
  gem.authors = ["Brad Heller"]
  gem.extensions = ['ext/json_extractor/extconf.rb']
  gem.files = Dir.glob('lib/**/*.rb') +
              Dir.glob('ext/**/*.{c,h,rb}')
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rake/extensiontask'
Rake::ExtensionTask.new('json_extractor') do |ext|
  ext.lib_dir = 'lib/json_extractor'
end

task :irb => [:compile] do
  ARGV.clear
  require File.expand_path('../lib/json_extractor', __FILE__)
  require 'irb'
  IRB.start
end
