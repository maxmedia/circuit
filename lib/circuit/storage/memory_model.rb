require 'active_support/concern'
require 'active_model/naming'
require 'active_model/attribute_methods'

module Circuit
  module Storage
    module MemoryModel
      extend ActiveSupport::Concern

      include ActiveModel::AttributeMethods
      include Compatibility::ActiveModel31
      attr_reader :attributes, :errors
      attr_accessor :name

      included do
        extend ActiveModel::Naming
        class_attribute :all
        self.all = Array.new
      end

      module ClassMethods
        def setup_attributes(*attrs)
          attribute_method_suffix '?'
          attribute_method_suffix '='
          define_attribute_methods attrs.collect(&:to_sym)
        end
      end

      def attributes=(hash)
        @attributes = hash.with_indifferent_access
      end

      def save!
        self.save ? true : raise("Invalid %s: %p"%[self.class, self.errors])
      end

      def persisted?
        @persisted
      end

      def persisted!(val=true)
        @persisted = val
      end

      def eql?(obj)
        obj.instance_of?(self.class) && obj.attributes == self.attributes
      end

      protected

      def attribute(key)
        attributes[key]
      end

      def attribute=(key, val)
        attributes[key] = val
      end

      def attribute?(attr)
        !attributes[attr.to_sym].blank?
      end

      def memory_model_setup
        @persisted = false
        @attributes = HashWithIndifferentAccess.new
        @errors = ActiveModel::Errors.new(self)
      end
    end
  end
end
