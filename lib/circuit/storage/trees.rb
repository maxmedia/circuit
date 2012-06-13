module Circuit
  module Storage
    module Trees
      autoload :Model,        'circuit/storage/trees/model'
      autoload :MemoryStore,  'circuit/storage/trees/memory_store'
      autoload :MongoidStore, 'circuit/storage/trees/mongoid_store'

      extend Circuit::Storage

      class UnimplementedError < CircuitError; end
      class NotFoundError < CircuitError; end

      class BaseStore
        def get(site, path)
          raise UnimplementedError, "#{self.class.to_s}#get not implemented."
        end

        def get!(site, path)
          get(site, path) or raise NotFoundError, "Path not found"
        end

        protected

        def find_nodes_for_path(root, path)
          nodes = [root]
          ::Rack::Request.path_segments(path).each do |fragment|
            node = nodes.last.find_child_by_fragment(fragment)
            return nil if node.nil?
            nodes << node
          end
          nodes
        end
      end
    end
  end
end
