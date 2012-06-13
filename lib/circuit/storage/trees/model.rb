require 'active_support/concern'
require 'active_model/validations'
require 'circuit/validators'

module Circuit
  module Storage
    module Trees
      module Model
        extend ActiveSupport::Concern

        module Validations
          extend ActiveSupport::Concern
          include ActiveModel::Validations

          included do
            validates :slug, slug: {allow_blank: true}, presence: {:unless => :root?}
            validates :behavior_klass, presence: true
            validates :parent, presence: true, :if => :slug?
          end
        end

        def root?
          parent.nil?
        end

        def behavior
          return nil if self.behavior_klass.blank?
          behavior_klass.constantize
        end

        def behavior=(klass)
          self.behavior_klass = klass.to_s
        end

        def find_child_by_fragment(segment)
          self.children.detect {|c| c.slug == segment}
        end

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
