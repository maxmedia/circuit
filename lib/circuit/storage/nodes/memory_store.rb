module Circuit
  module Storage
    module Nodes
      # Concrete node store for memory
      class MemoryStore < BaseStore
        # @param [Sites::Model] site to find path under
        # @param [String] path to find
        # @return [Array<Model>] array of nodes for each path segment
        def get(site, path)
          find_nodes_for_path(site.route, path)
        rescue NotFoundError
          return nil
        end

        # Concrete memory Node class
        class Node
          include Circuit::Storage::MemoryModel
          setup_attributes :slug, :behavior_klass, :site, :parent, :children

          # @!attribute slug
          #   @return [String] path segment slug

          # @!attribute behavior_klass
          #   @return [String] name of Behavior class or module

          # @!attribute site
          #   @return [Sites::Model] site

          # @!attribute parent
          #   @return [Sites::Node] parent node

          # @!attribute children
          #   @return [Array<Sites::Node>] array of child nodes

          include Circuit::Storage::Nodes::Model
          include Circuit::Storage::Nodes::Model::Validations

          def initialize(opts={})
            memory_model_setup
            behavior = opts.delete(:behavior) || opts.delete("behavior")
            self.attributes = opts
            self.slug = opts[:slug]
            self.behavior = behavior if behavior
            self.children ||= Array.new
          end

          # Save the Node to memory
          # @return [Boolean] `true` if the Node was saved
          def save
            return false if invalid?
            unless persisted?
              self.site.route = self if self.site
              self.parent.children << self if self.parent
              self.children.each {|c| c.parent = self}
              self.class.all << self
            end
            persisted!
          end
        end
      end
    end
  end
end
