module Circuit
  module Storage
    module Nodes
      autoload :Model,        'circuit/storage/nodes/model'
      autoload :MemoryStore,  'circuit/storage/nodes/memory_store'
      autoload :MongoidStore, 'circuit/storage/nodes/mongoid_store'

      extend Circuit::Storage

      # Raised when #get isn't overriden/implemented
      class UnimplementedError < CircuitError; end

      # Raised when a path is not found
      class NotFoundError < CircuitError; end

      # @abstract Subclass and override {#get}
      class BaseStore
        # @param [Sites::Model] site to find path under
        # @param [String] path to find
        # @return [Array<Model>] array of nodes for each path segment
        def get(site, path)
          raise UnimplementedError, "#{self.class.to_s}#get not implemented."
        end

        # @raise NotFoundError if the path cannot be found
        # @param (see #get)
        # @return [Model] Node Model
        # @see #get
        def get!(site, path)
          get(site, path) or raise NotFoundError, "Path not found"
        end

        protected

        # Iterates over the path segments to find the nodes
        # @param [Model] root node
        # @param [String] path to find
        # @return [Array<Model>] array of node Models
        # @see Rack::Request::ClassMethods#path_segments
        def find_nodes_for_path(root, path)
          raise(NotFoundError, "Root path not found") if root.nil?
          [root].tap do |result|
            ::Rack::Request.path_segments(path).each do |segment|
              next if segment.blank?
              # Find the segment and add it to the result array
              if node = result.last.find_child_by_segment(segment)
                result << node
              elsif result.last.finite?
                # Here, we didn't find the segment, and the last node we found is finite, so the
                # route is not found
                return nil
              else
                # This is the infinite route case
                break
              end
            end
          end
        end
      end
    end
  end
end
