module Circuit
  module Middleware
    # Raise if rewriting fails.
    class RewriteError < CircuitError ; end

    # Rewriter middleware
    # @example Use the middleware (in rackup)
    #   use Rewriter do |script_name, path_info|
    #         ["/pages", script_name+path_info]
    #       end
    # @example Use the middleware with Rack::Request object (in rackup)
    #   use Rewriter do |request|
    #         ["/site/#{request.site.id}"+request.script_name, request.path_info]
    #       end
    # @see http://rubydoc.info/gems/rack/Rack/Request Rack::Request documentation
    class Rewriter
      # @param [#call] app Rack app
      # @yield [script_name, path_info] `SCRIPT_NAME` and `PATH_INF`O values
      # @yield [Request] `Rack::Request` object
      # @yieldreturn [Array<String>] new `script_name` and `path_info`
      def initialize(app, &block)
        @app = app
        @block = block
      end

      # Executes the rewrite
      def call(env)
        begin
          request = ::Rack::Request.new(env)
          script_name, path_info, path = request.script_name.dup, request.path_info.dup, request.path
          if @block.arity == 1
            env["SCRIPT_NAME"], env["PATH_INFO"] = @block.call(request)
          else
            env["SCRIPT_NAME"], env["PATH_INFO"] = @block.call(script_name, path_info)
          end
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
