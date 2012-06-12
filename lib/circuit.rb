if Object.const_defined?(:Rails)
  require "circuit/railtie"
end
require 'logger'
require 'circuit/version'

module Circuit
  autoload :Behavior,   'circuit/behavior'
  autoload :Storage,    'circuit/storage'
  autoload :Rack,       'circuit/rack'

  # @param [Logger] logger for Circuit
  def self.logger=(logger)
    @logger = logger
  end

  # @return [Logger] logger for Circuit
  def self.logger
    @logger ||= ::Logger.new($stdout)
  end

  # @return [Storage::Sites::BaseStore] the Site storage instance
  def self.site_store() Storage::Sites.instance; end

  # @overload set_site_store(instance)
  #   @param [Storage::Sites::BaseStore] instance for the Site store
  #   @example Set the Site store
  #     Circuit.set_site_store Circuit::Storage::Sites::MongoidStore.new
  # @overload set_site_store(klass)
  #   @param [Class] klass to create instance for the Site store
  #   @example Set the Site store
  #     Circuit.set_site_store Circuit::Storage::Sites::MongoidStore
  # @overload set_site_store(symbol)
  #   @param [Symbol] symbol for a Site store class under Circuit::Storage::Sites
  #   @example Set the Site store
  #     Circuit.set_site_store :mongoid_store
  # @return [Storage::Sites::BaseStore] the Site storage instance
  def self.set_site_store(*args)
    Storage::Sites.set_instance(*args)
  end

  # @return [Storage::Trees::BaseStore] the Tree storage instance
  def self.tree_store() Storage::Trees.instance; end

  # @overload set_tree_store(instance)
  #   @param [Storage::Trees::BaseStore] instance for the Tree store
  #   @example Set the Tree store
  #     Circuit.set_tree_store Circuit::Storage::Trees::MongoidStore.new
  # @overload set_tree_store(klass)
  #   @param [Class] klass to create instance for the Tree store
  #   @example Set the Tree store
  #     Circuit.set_tree_store Circuit::Storage::Trees::MongoidStore
  # @overload set_tree_store(symbol)
  #   @param [Symbol] symbol for a Tree store class under Circuit::Storage::Trees
  #   @example Set the Tree store
  #     Circuit.set_tree_store :mongoid_store
  # @return [Storage::Trees::BaseStore] the Tree storage instance
  def self.set_tree_store(*args)
    Storage::Trees.set_instance(*args)
  end

  # Top-level error class for Circuit errorsr
  class CircuitError < StandardError; end

  # @return [true,false] true if running with ActiveModel 3.1
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
