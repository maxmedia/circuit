if Object.const_defined?(:Rails)
  require "circuit/railtie"
end
require 'logger'
require 'circuit/version'

module Circuit
  autoload :Behavior,   'circuit/behavior'
  autoload :Storage,    'circuit/storage'
  autoload :Rack,       'circuit/rack'

  def self.logger=(new_logger)
    @logger = new_logger
  end

  def self.logger
    @logger ||= ::Logger.new($stdout)
  end

  def self.site_store() Storage::Sites.instance; end
  def self.set_site_store(*args)
    Storage::Sites.set_instance(*args)
  end

  def self.tree_store() Storage::Trees.instance; end
  def self.set_tree_store(*args)
    Storage::Trees.set_instance(*args)
  end

  class CircuitError < StandardError; end

  def self.active_model_31?
    ActiveModel::VERSION::MAJOR == 3 and
    ActiveModel::VERSION::MINOR == 1
  end
end

module Behaviors
  autoload :Forward,                'behaviors/forward'
  autoload :MountByFragmentOrRemap, 'behaviors/mount_by_fragment_or_remap'
  autoload :RenderOK,               'behaviors/render_ok'
end
