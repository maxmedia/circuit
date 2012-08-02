module Circuit
  module Middleware
    # Fallthrough Middleware.  Fallsthrough to the application.
    # @example Use the middleware (in rackup)
    #   use Fallthrough
    class Fallthrough
      # @param [#call] app Rack app
      def initialize(app)
        @app = app
      end

      # Executes the rewrite
      def call(env)
        request = ::Rack::Request.new(env)
        request.env["PATH_INFO"] = request.path
        request.env["SCRIPT_NAME"] = ""
        ::Circuit.logger.info("[CIRCUIT] Fallthrough: '#{request.path}'")
        @app.call(env)
      end
    end
  end
end
