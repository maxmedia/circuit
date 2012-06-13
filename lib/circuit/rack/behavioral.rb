module Circuit
  module Rack
    class MissingSiteError < CircuitError; end

    class Behavioral
      def initialize(app)
        @app = app
      end

      def call(env)
        request = ::Rack::Request.new(env)

        unless request.site
          raise MissingSiteError, "Rack variable %s is missing"%[::Rack::Request::ENV_SITE]
        end

        result = remap!(request)
        return @app.call(request.env) if result == :not_found

        behavior = request.route.last.behavior
        result = rewrite_with_behavior! behavior, request
        return @app.call(request.env) if result == :rewrite_failed

        use = behavior.stack.to_a
        use = use.map { |middleware| proc { |app| middleware.new(app) } }
        use.reverse.inject(@app) { |a,e| e[a] }.call(request.env)
      end

      def remap!(request)
        route = ::Circuit.node_store.get(request.site, request.path)
        return :not_found if route.blank?

        request.route = route.take_while { |segment| remapable_behavior?(segment.behavior) }
        request.route << route[request.route.length] if route[request.route.length]
        request.route_path = request.route.last.path
        return :route_determined
      end

      def rewrite_with_behavior!(behavior, request)
        return :rewrite_not_configured unless behavior.respond_to?(:rewrite!)
        request.original_path = request.path
        behavior.rewrite! request
        ::Circuit.logger.info("[CIRCUIT] Rerouting: '#{request.original_path}'->'#{request.path}'")
        :rewritten
      rescue ::Circuit::Behavior::RewriteError => ex
        ::Circuit.logger.error("[CIRCUIT] Error: %p"%[ex])
        return :rewrite_failed
      end

      def remapable_behavior?(behavior)
        behavior.respond_to?(:remap_by_fragment) && behavior.remap_by_fragment
      end
    end
  end
end
