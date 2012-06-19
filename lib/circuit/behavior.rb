require 'active_support/concern'
require 'active_support/inflector'
require 'active_support/core_ext/module/delegation'
require 'pathname'

module Circuit
  module Behavior
    extend ActiveSupport::Concern

    # Raised when the path for a rackup file is indeterminate.
    class RackupPathError < Circuit::CircuitError; end

    # @param [String] str name of Behavior constant to get
    # @return [Behavior] Behavior constant
    def self.get(str)
      str.classify.constantize
    rescue NameError
      str = str.classify
      nesting = str.deconstantize
      nesting = (nesting.blank? ? Object : nesting.constantize)

      mod = Module.new do
          include Circuit::Behavior
          self.cru_path = Circuit.cru_path.join(str.classify.underscore+".cru")
          self.builder!
          class_eval %(def self.to_s() "#{str}"; end)
        end
      nesting.const_set(str.demodulize, mod)
    end

    module ClassMethods
      # Clones the builder into the subclass when using inheritance
      def inherited(subclass)
        subclass.builder = @builder.clone
      end

      # Indicates whether a Builder is defined or will be defined based on a rackup file
      # @return [Boolean] false if there is no Builder and no rackup file to create one
      def builder?
        !!@builder or self.cru_path.file?
      rescue RackupPathError
        false
      end

      # Creates an empty Builder object or parses the rackup file if it exists
      # @return [Builder] the Builder
      def builder!
        if self.cru_path.file?
          @builder = Circuit::Rack::Builder.parse_file(self.cru_path)
        else
          @builder = Circuit::Rack::Builder.new
        end
      end

      # Returns the Builder (and creates one if it doesn't exist yet)
      # @return [Builder] the Builder
      # @see #builder!
      def builder
        @builder ||= self.builder!
      end

      attr_writer :builder

      # @return [Pathname] the path to the rackup file
      # @raise [RackupPathError] if the rackup file path is indeterminate
      def cru_path
        if @cru_path.nil? and Circuit.cru_path.nil?
          raise RackupPathError, "Rackup path cannot be determined for #{self.to_s}"
        end
        @cru_path ||= Circuit.cru_path.join(self.class.to_s.underscore)
      end

      # Sets the rackup file path and clears the #builder
      # @param [Pathname,String] pathname of the rackup file
      def cru_path=(pathname)
        @cru_path = (pathname.is_a?(Pathname) ? pathname : Pathname.new(pathname.to_s))
        self.builder = nil
      end

      # @!method use(middleware, *args, &block)
      #   @see http://rubydoc.info/gems/rack/Rack/Builder#use-instance_method
      #        ::Rack::Builder#use

      # @!method run(app)
      #   @see http://rubydoc.info/gems/rack/Rack/Builder#run-instance_method
      #        ::Rack::Builder#run

      # @!method map(path, &block)
      #   @see http://rubydoc.info/gems/rack/Rack/Builder#map-instance_method
      #        ::Rack::Builder#map

      # @!method useto_app
      #   @see http://rubydoc.info/gems/rack/Rack/Builder#to_app-instance_method
      #        ::Rack::Builder#to_app

      delegate :use, :run, :map, :to_app, :to => :builder
    end
  end
end
