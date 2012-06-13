require 'mongoid/tree'

module Circuit
  module Storage
    module Trees
      class MongoidStore < BaseStore
        def get(site, path)
          root = site.route
          return nil if root.nil?
          find_nodes_for_path(root, path)
        end

        class Tree
          include Model
          include Model::Validations
          include Mongoid::Document
          include Mongoid::Tree
          include Mongoid::Tree::Ordering
          include Mongoid::Tree::Traversal

          store_in collection: "circuit_trees"

          field :slug, type: String
          field :behavior_klass, type: String

          belongs_to :site, class_name: "Circuit::Site",
                            inverse_of: :route

          def find_child_by_fragment(fragment)
            self.children.where(slug: fragment).first
          end
        end
      end
    end
  end
end
