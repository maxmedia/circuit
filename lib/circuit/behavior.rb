require 'active_support/concern'

module Circuit
  module Behavior
    autoload :Stack, 'circuit/behavior/stack'

    class RewriteException < Exception ; end

    extend ActiveSupport::Concern

    module ClassMethods
      # creates and memoizes a stack object that will hold the middleware
      # objects attached to the behavior.
      #
      # @returns [Stack] newly create stack or superclass duplicate
      def stack
        @stack ||= (is_mixing_behaviors? ? superclass.stack.dup : Stack.new)
      end

      # defines accessor methods for commonly used stack configuration
      # methods. This would allow you to define behaviors that inherit
      # stacks form their parents, configure them, without affecting the
      # parents stack object.
      #
      # see lib/circuit/behaviors/stack.rb for mor details.
      [:use, :delete, :insert, :insert_after, :insert_before, :swap].each do |methud|
        module_eval <<-METHOD
          def #{methud.to_s}(*args)
            self.stack.#{methud.to_s} *args
          end
        METHOD
      end

      # if the mixer has included `Circuit::Behavior`
      #
      # @returns [TrueClass,FalseClass]
      def is_mixing_behaviors?
        superclass and superclass.included_modules.include?(::Circuit::Behavior)
      end
    end
  end
end
