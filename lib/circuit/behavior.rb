require 'active_support/concern'
require 'active_support/core_ext/module/delegation'

module Circuit
  module Behavior
    autoload :Stack, 'circuit/behavior/stack'

    # Raised in any case a rewrite fails.
    class RewriteException < Exception ; end

    extend ActiveSupport::Concern

    module ClassMethods
      # Creates and memoizes a stack object that will hold the middleware
      # objects attached to the behavior.
      #
      # @return [Stack] newly create stack or superclass duplicate
      def stack
        @stack ||= (is_mixing_behaviors? ? superclass.stack.dup : Stack.new)
      end

      # Defines accessor methods for commonly used stack configuration
      # methods. This would allow you to define behaviors that inherit
      # stacks form their parents, configure them, without affecting the
      # parents stack object.

      # @!method use(*args)
      #   @see Circuit::Behavior::Stack#use
      # @!method delete(*args)
      #   @see Circuit::Behavior::Stack#delete
      # @!method insert(*args)
      #   @see Circuit::Behavior::Stack#insert
      # @!method insert_after(*args)
      #   @see Circuit::Behavior::Stack#insert_after
      # @!method insert_before(*args)
      #   @see Circuit::Behavior::Stack#insert_before
      # @!method swap(*args)
      #   @see Circuit::Behavior::Stack@swap
      delegate :use, :delete, :insert, :insert_after, :insert_before, :swap, to: :stack

      # Indicates if the mixer has included `Circuit::Behavior`
      #
      # @return [true,false]
      def is_mixing_behaviors?
        superclass and superclass.included_modules.include?(::Circuit::Behavior)
      end
    end
  end
end
