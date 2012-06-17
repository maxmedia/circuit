module Circuit
  module Storage
    module Sites
      autoload :Model,        'circuit/storage/sites/model'
      autoload :MemoryStore,  'circuit/storage/sites/memory_store'
      autoload :MongoidStore, 'circuit/storage/sites/mongoid_store'

      extend Circuit::Storage

      # Raised when #get isn't overriden/implemented
      class UnimplementedError < CircuitError; end

      # Raised when a site is not found
      class NotFoundError < CircuitError; end

      # Raised when multiple sites are found for the same host
      class MultipleFoundError < CircuitError; end

      # @abstract Subclass and override {#get}
      class BaseStore
        # @raise MultipleFoundError if multiple sites are found for the given `host`
        # @param [String] host to find
        # @return [Model] site
        def get(host)
          raise UnimplementedError, "#{self.class.to_s}#get not implemented."
        end

        # @raise NotFoundError if the site is not found
        # @param (see #get)
        # @return [Model] site model
        # @see #get
        def get!(host)
          get(host) or raise NotFoundError, "Host not found"
        end
      end
    end
  end
end
