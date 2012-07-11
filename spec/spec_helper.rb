require 'rubygems'

if RUBY_VERSION =~ /^1\.9\./
  require 'simplecov'
  SimpleCov.start do
    add_filter "/lib/circuit/version.rb"
    add_filter "/spec/"
  end
end

require 'bundler'

required_groups = [:default, :development]

# Require gems and attempt to load mongo
begin
  Bundler.require *(required_groups+[:mongo])
rescue LoadError
  Bundler.require *required_groups
end
# Determine if we want to run tests with mongo (i.e. whether mongo was loaded)
$mongo_tests = !!Bundler.definition.requested_specs.detect {|s| s.name == "mongo"}

require 'combustion'

require 'machinist'
require 'machinist/mongoid' if $mongo_tests

Mongoid.load! "spec/internal/config/mongoid.yml" if $mongo_tests

Combustion.initialize! :action_controller, :action_view, :sprockets

require 'rails/mongoid' if $mongo_tests
require 'rspec/rails'
require 'rspec/rails/mocha'
require 'support/blueprints'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f|  require f}

RSpec.configure do |config|
  config.mock_with :mocha
  config.include SpecHelpers::RackHelpers

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
    Circuit::Storage::Nodes::MemoryStore::Node.all.clear
  end

  config.before(:each) { stub_time! }
end

# freeze time, so time tests appear to run without time passing.
def stub_time!
  @time = Time.zone.now
  Time.zone.stubs(:now).returns(@time)
end
