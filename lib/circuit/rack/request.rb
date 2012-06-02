require 'active_support/concern'

module Circuit
  module Rack
    module Request
      extend ActiveSupport::Concern

      ENV_SITE          = 'rack.circuit.site'
      ENV_ROUTE         = 'rack.circuit.route'
      ENV_ROUTE_PATH    = 'rack.circuit.route_path'
      ENV_ORIGINAL_PATH = 'rack.circuit.original_path'

      module ClassMethods
        def path_segments(path)
          path.gsub(/^\/+/,'').split(/\/+/).select { |seg| !seg.blank? }
        end
      end

      # def initialize(env)
      #   super
      #
      #   @env[ENV_ROUTE] ||= nil
      # end

      def site() @env[ENV_SITE]; end
      def site=(site)  @env[ENV_SITE] = site; end

      def route() @env[ENV_ROUTE]; end
      def route=(route) @env[ENV_ROUTE] = route; end

      def route_path() @env[ENV_ROUTE_PATH]; end
      def route_path=(route_path) @env[ENV_ROUTE_PATH] = route_path; end

      def original_path() @env[ENV_ORIGINAL_PATH]; end
      def original_path=(original_path) @env[ENV_ORIGINAL_PATH] = original_path; end

      def path=(new_path)
        @env["PATH_INFO"] = new_path
        @env["SCRIPT_NAME"] = ""
      end

      def path_segments
        self.class.path_segments self.path
      end
    end
  end
end
