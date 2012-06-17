module Circuit
  module Storage
    module Nodes
      autoload :Model,        'circuit/storage/nodes/model'
      autoload :MemoryStore,  'circuit/storage/nodes/memory_store'
      autoload :MongoidStore, 'circuit/storage/nodes/mongoid_store'

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
          raise(NotFoundError, "Root path not found") if root.nil?
          [root].tap do |result|
            ::Rack::Request.path_segments(path).each do |segment|
              next if segment.blank?
              if node = result.last.find_child_by_segment(segment)
                result << node
              else
                break
              end
            end
          end
        end
      end
    end
  end
end
