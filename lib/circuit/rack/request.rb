require 'active_support/concern'

module Circuit
  module Rack
    # Extensions made to the ::Rack::Request class
    # @see http://rubydoc.info/gems/rack/Rack/Request ::Rack::Request API documentation
    # @see ClassMethods
    module Request
      extend ActiveSupport::Concern

      # Key for storing the Circuit::Site instance
      ENV_SITE          = 'rack.circuit.site'

      # Key for storing the array of Circuit::Node instances
      ENV_ROUTE         = 'rack.circuit.route'

      # Key for storing original parameters that Circuit modifies.
      ENV_ORIGINALS     = 'rack.circuit.originals'

      module ClassMethods
        # Parses a URI path String into its segments
        # @param [String] path to parse
        # @return [Array<String>] segment parts; first segment will be `nil` if
        #                         it is the root (i.e. the path is absolute)
        # @see http://tools.ietf.org/html/rfc2396#section-3.3 RFC 2396: Uniform
        #      Resource Identifiers (URI): Generic Syntax - Path Component
        def path_segments(path)
          path.gsub(/^\/+/,'').split(/\/+/).select { |seg| !seg.blank? }.tap do |result|
            result.unshift nil if path =~ /^\//
          end
        end
      end

      # @return [Circuit::Site] site from the environment
      def site() @env[ENV_SITE]; end

      # @param [Circuit::Site] site to set into the environment
      def site=(site)  @env[ENV_SITE] = site; end

      # @return [Array<Circuit::Node>] the array of nodes that make up the
      #                                route
      def route() @env[ENV_ROUTE]; end

      # Sets the route and modifies the `PATH_INFO` and `SCRIPT_NAME` variables
      # to conform to the route. This means that that route's path will be set
      # as the `SCRIPT_NAME` and the remainder of the path will be set as the
      # `PATH_INFO`.  Also, the original `PATH_INFO` and `SCRIPT_NAME`
      # values are copied into the originals key.
      # @param [Array<Circuit::Node>] route the array of nodes that make up the route
      def route=(route)
        raise(Circuit::Error, "Route has already been set") if self.route
        save_original_path_envs
        @env["PATH_INFO"] = "/"+path_segments[route.length..-1].join("/")
        @env["PATH_INFO"] = "" if @env["PATH_INFO"] == "/"
        @env["SCRIPT_NAME"] = route.last.path
        @env["SCRIPT_NAME"] = "" if @env["SCRIPT_NAME"] == "/" and @env["PATH_INFO"].present?
        @env[ENV_ROUTE] = route;
      end

      # @return [String] the route's path (aka. the `SCRIPT_NAME`)
      def route_path() @env["SCRIPT_NAME"]; end

      # @return [Hash] the originals of any keys that Circuit modifies are
      #                first copied into this Hash
      def circuit_originals() @env[ENV_ORIGINALS] ||= {}; end

      # @return [Array<String>] segment parts; first segment will be `nil` if
      #                         it is the root (i.e. the path is absolute)
      # @see ClassMethods#path_segments
      def path_segments
        self.class.path_segments self.path
      end

      # Saves the original path keys into #circuit_originals (i.e. `PATH_INFO`
      # and `SCRIPT_NAME`)
      def save_original_path_envs
        circuit_originals["PATH_INFO"] = @env["PATH_INFO"]
        circuit_originals["SCRIPT_NAME"] = @env["SCRIPT_NAME"]
      end
    end
  end
end
