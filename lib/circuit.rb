if Object.const_defined?(:Rails)
  require "circuit/railtie"
end
require 'logger'
require 'circuit/version'

module Circuit
  autoload :Middleware, 'circuit/middleware'
  autoload :Rack,       'circuit/rack'
  autoload :Behavior,   'circuit/behavior'
  autoload :Storage,    'circuit/storage'

  # @param [Logger] logger for Circuit
  def self.logger=(logger)
    @logger = logger
  end

  # @return [Logger] logger for Circuit
  def self.logger
    @logger ||= ::Logger.new($stdout)
  end

  # @param [Pathname,String] pathname directory for behaviors, .cru, and .ru files
  def self.cru_path=(pathname)
    @cru_path = (pathname.is_a?(Pathname) ? pathname : Pathname.new(pathname.to_s))
  end

  # @return [Pathname] pathname directory for behaviors, .cru, and .ru files
  def self.cru_path() @cru_path; end

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

  # @return [Storage::Nodes::BaseStore] the Node storage instance
  def self.node_store() Storage::Nodes.instance; end

  # @overload set_node_store(instance)
  #   @param [Storage::Nodes::BaseStore] instance for the Node store
  #   @example Set the Node store
  #     Circuit.set_node_store Circuit::Storage::Nodes::MongoidStore.new
  # @overload set_node_store(klass)
  #   @param [Class] klass to create instance for the Node store
  #   @example Set the Node store
  #     Circuit.set_node_store Circuit::Storage::Nodes::MongoidStore
  # @overload set_node_store(symbol)
  #   @param [Symbol] symbol for a Node store class under Circuit::Storage::Nodes
  #   @example Set the Node store
  #     Circuit.set_node_store :mongoid_store
  # @return [Storage::Nodes::BaseStore] the Node storage instance
  def self.set_node_store(*args)
    Storage::Nodes.set_instance(*args)
  end

  # Top-level error class for Circuit errorsr
  class CircuitError < StandardError; end

  # @return [true,false] true if running with ActiveModel 3.1
  def self.active_model_31?
    ActiveModel::VERSION::MAJOR == 3 and
    ActiveModel::VERSION::MINOR == 1
  end
end
