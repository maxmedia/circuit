require 'mongoid/tree'

module Circuit
  module Storage
    module Nodes
      # Concrete nodes store for Mongoid
      class MongoidStore < BaseStore
        # @param [Sites::Model] site to find path under
        # @param [String] path to find
        # @return [Array<Model>] array of nodes for each path segment
        def get(site, path)
          find_nodes_for_path(site.route, path)
        rescue NotFoundError
          return nil
        end

        # Concrete Mongoid Node class
        class Node
          include Model
          include Model::Validations
          include Mongoid::Document
          include Mongoid::Tree
          include Mongoid::Tree::Ordering
          include Mongoid::Tree::Traversal

          store_in collection: "circuit_nodes"

          field :slug, type: String
          field :behavior_klass, type: String

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

          belongs_to :site, class_name: "Circuit::Site",
                            inverse_of: :route

          def find_child_by_segment(segment)
            self.children.where(slug: segment).first
          end
        end
      end
    end
  end
end
