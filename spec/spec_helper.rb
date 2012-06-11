require 'rubygems'
require 'simplecov'
SimpleCov.start do
  add_filter "/lib/circuit/version.rb"
  add_filter "/spec/"
end

require 'bundler'

require 'simplecov'
SimpleCov.start

required_groups = [:default, :development]

$mongo_tests = true
begin
  Bundler.require *required_groups, :mongo
rescue LoadError
  Bundler.require *required_groups
  $mongo_tests = false
end

require 'combustion'
require 'capybara/rspec'

require 'machinist'
require 'machinist/mongoid' if $mongo_tests

Mongoid.load! "spec/internal/config/mongoid.yml" if $mongo_tests

Combustion.initialize! :action_controller, :action_view, :sprockets

require 'rails/mongoid' if $mongo_tests
require 'rspec/rails'
require 'capybara/rails'
require 'rspec/rails/mocha'
require 'support/blueprints'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f|  require f}

RSpec.configure do |config|
  config.mock_with :mocha

  if $mongo_tests
    config.include Mongoid::Matchers

    config.after(:each) do
      Mongoid.master.collections.select do |collection|
        collection.name !~ /system/
      end.each(&:drop)
    end

    # Clean up the database
    require 'database_cleaner'
    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.orm = "mongoid"
    end

    config.before(:each) do
      DatabaseCleaner.clean
    end
  end

  config.after(:each) do
    Circuit::Storage::Sites::MemoryStore::Site.all.clear
    Circuit::Storage::Trees::MemoryStore::Tree.all.clear
  end

  config.before(:each) { stub_time! }
end

# freeze time, so time tests appear to run without time passing.
def stub_time!
  @time = Time.zone.now
  Time.zone.stubs(:now).returns(@time)
end
