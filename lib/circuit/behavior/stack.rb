require 'active_support/inflector/methods'
require 'active_support/dependencies'
require 'active_support/core_ext/module/delegation'
require 'monitor'

module Circuit
  module Behavior
    # Behavior::Stack
    # ---------------
    #
    # Behavior stacks are stacks of middleware that are inherited.
    #
    # This code is originally inspired by rails middleware configs but has
    # been altered to support inherited stacks and some other functionality.
    class Stack
      # Raised when a requested index does not exist in a Stack.
      class NoSuchObjectError < CircuitError; end

      include Enumerable

      # @return [Array] array of middleware objects that the stack operates on
      attr_accessor :objects

      # @!method empty?
      #   @return [true,false] true if the Stack is empty.
      #   @see Array#empty?
      # @!method each
      #   Iterates over each middleware in the Stack
      #   @yield [Object] each middleware object
      #   @see Array#each
      # @!method size
      #   @return [Integer] number of middlewares in the stack
      #   @see Array#size
      # @!method last
      #   @return [Object] last middleware object in the stack
      #   @see Array#last
      # @!method clear
      #   Remove all middleware objects from the Stack
      #   @see Array#clear
      delegate :empty?, :each, :size, :last, :clear, to: :objects

      def initialize(*args, &block)
        @@monitor = Monitor.new
        @objects ||= []
        configure &block
        @objects.uniq!
      end

      # Duplicates the stack and it's middleware objects
      # @return [Stack] duplicated stack
      def dup
        self.class.new.tap { |obj| reverse_dup_copy obj }
      end

      # Configure the Stack in a synchronized block
      # @yield [Stack] the middleware Stack
      def configure
        @@monitor.synchronize {
          yield(self) if block_given?
        }
      end

      # Insert a middleware object into the stack at target index
      # @param [Integer,Object]     target middleware index or object to insert
      #                             at
      # @param [Object]             middleware object to insert
      # @raise [NoSuchObjectError]  if the target middleware object is not 
      #                             found in the Stack
      def insert(target, middleware)
        index = assert_index(target, :before)
        template = middleware
        objects.insert(index, template)
      end
      alias_method :insert_before, :insert

      # Insert a middleware object into the stack after target index
      # @param [Integer,Object]     target middleware index or object to insert
      #                             after
      # @param [Object]             middleware object to insert
      # @raise [NoSuchObjectError]  if the target middleware object is not 
      #                             found in the Stack
      def insert_after(target, middleware)
        index = assert_index(target, :after)
        insert(index + 1, middleware)
      end

      # Insert a middleware object into the stack in place of a target 
      # middleware object
      # @param [Integer,Object]     target middleware index or object to swap
      #                             out
      # @param [Object]             middleware to swap in
      # @raise [NoSuchObjectError]  if the target middleware object is not 
      #                             found in the Stack
      # @return [Object]            target middleware that was swapped-out of
      #                             the stack
      def swap(target, middleware)
        insert_before(target, middleware)
        delete(target)
      end

      # Delete a middleware from the stack
      # @param [Integer,Object] target middleware index or object to delete
      def delete(target)
        index = assert_index(target, :at)
        objects.delete_at index
      end
      alias_method :skip, :delete

      # Append the middleware object to the end of Stack
      # @param [Object] middleware object to append
      def use(middleware, &block)
        template = middleware
        objects.push(template)
      end

      protected

      # Validates the presence of the target middleware object when trying to insert `where`.
      # @param [Integer,Object]     target middleware index or object to find
      # @param [Symbol]             where to insert -- `:before` or `:after`
      # @raise  [NoSuchObjectError] if the target is not in the Stack
      # @return [Integer]           index of the target object
      def assert_index(target, where)
        i = target.is_a?(Integer) ? target : objects.index(target)
        raise NoSuchObjectError, "No such stack object to insert #{where}: #{target.inspect}" unless i
        i
      end

      private

      # sets objects from another stacks' objects.
      # TODO: validate other is a kind of stack
      def reverse_dup_copy(new_stack)
        new_stack.objects = self.objects.dup
      end
    end
  end
end
