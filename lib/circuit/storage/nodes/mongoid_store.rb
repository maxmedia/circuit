require 'active_support/concern'
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
          find_nodes_for_path(site.root, path)
        rescue NotFoundError
          return nil
        end

        # Mongoid Node module
        # 
        # *Remember to setup your `belongs_to :site` association.*
        module Node
          extend ActiveSupport::Concern

          # @!attribute slug
          #   @return [String] path segment slug

          # @!attribute behavior_klass
          #   @return [String] name of Behavior class or module

          # @!attribute parent
          #   @return [Sites::Node] parent node

          # @!attribute children
          #   @return [Array<Sites::Node>] array of child nodes

          # *Setup #site as a `belongs_to` association in your concrete Node class*
          # @!attribute site
          #   @return [Sites::Model] site

          included do
            field :slug, :type => String
            field :behavior_klass, :type => String
          end

          include Model
          include Model::Validations
          include Mongoid::Document
          include Mongoid::Tree
          include Mongoid::Tree::Ordering
          include Mongoid::Tree::Traversal

          def find_child_by_segment(segment)
            self.children.where(:slug => segment).first
          end
        end
      end
    end
  end
end
