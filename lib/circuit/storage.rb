require 'active_support/core_ext/string/inflections'

module Circuit
  module Storage
    autoload :MemoryModel,  'circuit/storage/memory_model'
    autoload :Sites,        'circuit/storage/sites'
    autoload :Trees,        'circuit/storage/trees'

    class InstanceUndefinedError < CircuitError
      def initialize(msg="Storage instance is undefined.")
        super(msg)
      end
    end

    def instance
      @instance || raise(InstanceUndefinedError)
    end

    def set_instance(*args)
      klass = nil

      case args.first
      when Trees::BaseStore, Sites::BaseStore
        @instance = args.first
      when Class
        klass = args.first
      when String, Symbol
        # TODO do we need to fall up the module hiearchy to find the constant?
        #      (e.g. a store defined in the Kernel namespace?)
        klass = const_get(args.first.to_s.camelize)
      else
        raise ArgumentError, "Unexpected type for storage instance: %s"%[args.first.class]
      end

      if klass
        @instance = klass.new(*args[1..-1])
      end

      case @instance
      when Trees::BaseStore
        ::Circuit.const_set(:Tree, @instance.class.const_get(:Tree))
      when Sites::BaseStore
        ::Circuit.const_set(:Site, @instance.class.const_get(:Site))
      else
        bad_instance = @instance; @instance = nil
        raise ArgumentError, "Cannot determine a Site or Tree class for storage type: %s"%[bad_instance.class]
      end

      @instance
    end
  end
end
