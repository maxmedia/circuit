if Object.const_defined?(:Rails)
  require "circuit/railtie"
end
require 'logger'
require 'circuit/version'
require 'circuit/compatibility'
require 'active_support/configurable'
require 'dionysus/configuration_callbacks'

module Circuit
  autoload :Middleware, 'circuit/middleware'
  autoload :Rack,       'circuit/rack'
  autoload :Behavior,   'circuit/behavior'
  autoload :Storage,    'circuit/storage'

  # Top-level error class for Circuit errorsr
  class CircuitError < StandardError; end

  # @!attribute [r] config
  #   Maintains configuration values for `logger`, `cru_path`, `site_store`,
  #   and `node_store`
  #   @return [ActiveSupport::Configurable::Configuration] configuration
  #   @see http://rubydoc.info/gems/activesupport/ActiveSupport/Configurable/ClassMethods#config-instance_method

  # @!method configure()
  #   Configure Circuit
  #   @yield [ActiveSupport::Configurable::Configuration] configuration object
  #   @see http://rubydoc.info/gems/activesupport/ActiveSupport/Configurable/ClassMethods#configure-instance_method
  include ActiveSupport::Configurable
  include Dionysus::ConfigurationCallbacks
  config_accessor :logger, :cru_path, :site_store, :node_store,
                  :instance_reader => false,
                  :instance_writer => false

  # @!method logger=(logger)
  #   @!scope class
  #   @param [Logger] logger for Circuit
  #   @return [Logger] logger for Circuit

  # @!method logger
  #   @!scope class
  #   @return [Logger] logger for Circuit

  # @!method cru_path=(pathname)
  #   @!scope class
  #   @param [Pathname,String] pathname directory for behaviors, .cru, and .ru files
  #   @return [Pathname] pathname directory for behaviors, .cru, and .ru files

  # @!method cru_path
  #   @!scope class
  #   @return [Pathname] pathname directory for behaviors, .cru, and .ru files

  # @!method site_store
  #   @!scope class
  #   @return [Storage::Sites::BaseStore] the Site storage instance

  # @!method node_store
  #   @!scope class
  #   @return [Storage::Nodes::BaseStore] the Node storage instance
  configure do |c|
    c.logger = ::Logger.new($stdout)

    c.after :set, :cru_path do
      val = _get(:cru_path)
      if val and !val.is_a?(Pathname)
        _set(:cru_path, Pathname.new(val.to_s))
      end
    end

    c.forward :get, :site_store, Storage::Sites, :instance
    c.forward :get, :node_store, Storage::Nodes, :instance
  end

  config.instance_exec do
    def site_store=(args)
      Storage::Sites.set_instance(*args)
    end
    def node_store=(args)
      Storage::Nodes.set_instance(*args)
    end
  end

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
  # @see Storage.set_instance
  def self.set_site_store(*args)
    config.site_store = args
  end

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
  # @see Storage.set_instance
  def self.set_node_store(*args)
    config.node_store = args
  end

  # @return [Pathname] path to the vendor directory
  def self.vendor_path
    Pathname.new(__FILE__).expand_path.dirname.join("..", "vendor")
  end
end

Circuit::Compatibility.make_compatible
