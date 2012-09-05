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
        ::Circuit.logger.info("[CIRCUIT] Fallthrough: '#{env["PATH_INFO"]}'")
        @app.call(env)
      end
    end
  end
end
