require 'active_support/inflector'

module Circuit
  module Storage
    autoload :MemoryModel,  'circuit/storage/memory_model'
    autoload :Sites,        'circuit/storage/sites'
    autoload :Nodes,        'circuit/storage/nodes'

    # Raised if a storage instance is undefined.
    class InstanceUndefinedError < CircuitError
      def initialize(msg="Storage instance is undefined.")
        super(msg)
      end
    end

    # @raise InstanceUndefinedError if the instance isn't defined
    # @return [Circuit::Storage::Nodes::BaseStore,Circuit::Storage::Sites::BaseStore]
    #         the storage instance
    def instance
      @instance || raise(InstanceUndefinedError)
    end

    # Set the storage instance and alias the `Node` or `Site` model under
    # `Circuit` as `Circuit::Node` or `Circuit::Site`.
    #
    # @raise ArgumentError if the storage instance or the `Site` or `Node` 
    #                      model cannot be determined
    # @overload set_instance(instance)
    #   @param [Circuit::Storage::Nodes::BaseStore,Circuit::Storage::Sites::BaseStore]
    #          instance storage instance
    #   @return [Circuit::Storage::Nodes::BaseStore,Circuit::Storage::Sites::BaseStore]
    #           storage instance
    # @overload set_instance(klass_or_name, *args)
    #   @param [Class,String,Symbol] klass_or_name class or name of class 
    #                                (under Circuit::Storage::Nodes or 
    #                                Circuit::Storage::Sites) for storage 
    #                                instance
    #   @param [Array] args any arguments to instantiate the storage instance
    #   @return [Circuit::Storage::Nodes::BaseStore,Circuit::Storage::Sites::BaseStore]
    #           storage instance
    def set_instance(*args)
      klass = nil

      case args.first
      when Nodes::BaseStore, Sites::BaseStore
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

      @instance
    end
  end
end
