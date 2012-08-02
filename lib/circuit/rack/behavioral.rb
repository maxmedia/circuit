module Circuit
  module Rack
    # Raised if the `rack.circuit.site` rack variable is not defined (or `nil`)
    class MissingSiteError < CircuitError; end

    # Finds the route (Array of Nodes) for the request, and executes the 
    # route's behavior.  Returns a 404 if an appropriate route is not found.
    class Behavioral
      def initialize(app)
        @app = app
      end

      def call(env)
        request = ::Rack::Request.new(env)

        unless request.site
          raise MissingSiteError, "Rack variable %s is missing"%[::Rack::Request::ENV_SITE]
        end

        log_request(request)

        remap! request
        request.route.last.behavior.builder.tap do |builder|
          builder.run(@app) unless builder.app?
        end.call(env)
      rescue ::Circuit::Storage::Nodes::NotFoundError
        [404, {"Content-Type" => "text/plain"}, ["Not Found"]]
      end

    private

      def remap(request)
        route = ::Circuit.node_store.get(request.site, request.path)
        return nil if route.blank?

        request.route = route
        return request
      end

      def remap!(request)
        if result = remap(request)
          result
        else
          raise ::Circuit::Storage::Nodes::NotFoundError, "Path not found"
        end
      end

      def log_request(request)
        ln = "[CIRCUIT] "+%w[HOST SCRIPT_NAME PATH_INFO].map {|k| k+": %p"}.join(" ")
        ::Circuit.logger.info(ln % [request.host, request.script_name, request.path_info])
      end
    end
  end
end
