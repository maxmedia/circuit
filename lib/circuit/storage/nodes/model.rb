require 'active_support/concern'
require 'active_model/validations'
require 'circuit/validators'

module Circuit
  module Storage
    module Nodes
      # @abstract include into a Class or Module to setup the necessary methods
      # for a Node model
      module Model
        extend ActiveSupport::Concern

        # Validations for Node models
        # * validates the slug's format and presence when not the root
        # * validates the presence of the behavior_klass
        # * validates the presence of the parent if the slug is defined
        # @see Circuit::Validators::SlugValidator
        # @abstract include into a Node class or Module to add the Validations
        module Validations
          extend ActiveSupport::Concern
          include ActiveModel::Validations

          included do
            validates :slug, slug: {allow_blank: true}, presence: {:unless => :root?}
            validates :behavior_klass, presence: true
            validates :parent, presence: true, :if => :slug?
          end
        end

        # @return [Boolean] `false` if the parent is `nil`
        def root?
          parent.nil?
        end

        # @return [Class,Module] Behavior class or module for the behavior_klass
        # @see Behavior#get
        def behavior
          return nil if self.behavior_klass.blank?
          Behavior.get(behavior_klass)
        end

        # @param [Class,Module] klass Module or Class to set the behavior_klass
        def behavior=(klass)
          self.behavior_klass = klass.to_s
        end

        # @param [String] segment path segment
        # @return [Model] child for the segment or `nil` if not found
        def find_child_by_segment(segment)
          self.children.detect {|c| c.slug == segment}
        end

        # Walks the tree and forms the full path to the Node
        # @return [String] full path down to this node
        def path
          result = []
          node = self
          while node.parent
            result.unshift node.slug
            node = node.parent
          end
          "/"+result.join("/")
        end
      end
    end
  end
end
