require 'active_support/concern'

module SimpleMachinable
  extend ActiveSupport::Concern

  class SimpleBlueprint < Machinist::Blueprint
    def make!(attributes={})
      make(attributes).tap(&:save!)
    end
  end

  included do
    extend Machinist::Machinable
    # ClassMethods is included *before* the included block, so blueprint_class
    # would be overriden by the extend if it were in the ClassMethods module
    class_eval do
      def self.blueprint_class
        SimpleBlueprint
      end
    end
  end

  def self.ensure_machinable(*klasses)
    klasses.each do |klass|
      next if klass.respond_to?(:blueprint)
      klass.send(:include, SimpleMachinable)
    end
  end
end
