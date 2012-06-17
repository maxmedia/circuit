module Circuit
  module Middleware
    # Raise if rewriting fails.
    class RewriteError < CircuitError ; end

    class Rewriter
      def initialize(app, &block)
        @app = app
        @block = block
      end

      def call(env)
        begin
          request = ::Rack::Request.new(env)
          script_name, path_info, path = request.script_name, request.path_info, request.path
          env["SCRIPT_NAME"], env["PATH_INFO"] = @block.call(script_name, path_info)
          if script_name != env["SCRIPT_NAME"] or path_info != env["PATH_INFO"]
            ::Circuit.logger.info("[CIRCUIT] Rewriting: '#{path}'->'#{request.path}'")
          end
        rescue RewriteError => ex
          headline = "[CIRCUIT] Rewrite Error"
          ::Circuit.logger.error("%s: %s\n%s  %s"%[headline, ex.message, " "*headline.length, ex.backtrace.first])
        end
        @app.call(env)
      end
    end
  end
end
