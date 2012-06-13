module Circuit
  module Storage
    module Sites
      autoload :Model,        'circuit/storage/sites/model'
      autoload :MemoryStore,  'circuit/storage/sites/memory_store'
      autoload :MongoidStore, 'circuit/storage/sites/mongoid_store'

      extend Circuit::Storage

      class UnimplementedError < CircuitError; end
      class NotFoundError < CircuitError; end
      class MultipleFoundError < CircuitError; end

      class BaseStore
        def get(host)
          raise UnimplementedError, "#{self.class.to_s}#get not implemented."
        end

        def get!(host)
          get(host) or raise NotFoundError, "Host not found"
        end
      end
    end
  end
end
