require 'active_support/concern'

module Circuit
  module Storage
    module Nodes
      # Concrete node store for memory
      class MemoryStore < BaseStore
        # @param [Sites::Model] site to find path under
        # @param [String] path to find
        # @return [Array<Model>] array of nodes for each path segment
        # @raise [NotFoundError] if the path is not found and not infinite
        def get(site, path)
          find_nodes_for_path(site.root, path)
        end

        # In-memory Node module
        module Node
          extend ActiveSupport::Concern

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

          included do
            setup_attributes :slug, :behavior_klass, :site, :parent, :children, :infinite
          end

          include Circuit::Storage::MemoryModel
          include Circuit::Storage::Nodes::Model
          include Circuit::Storage::Nodes::Model::Validations

          def initialize(opts={})
            memory_model_setup
            behavior = opts.delete(:behavior) || opts.delete("behavior")
            self.attributes = opts
            self.slug = opts[:slug]
            self.behavior = behavior if behavior
            self.children ||= Array.new
            self.infinite = opts[:infinite]
          end

          # Save the Node to memory
          # @return [Boolean] `true` if the Node was saved
          def save
            return false if invalid?
            unless persisted?
              self.site.root = self if self.site
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
