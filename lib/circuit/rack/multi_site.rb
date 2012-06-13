module Circuit
  module Rack
    class MultiSite
      def initialize(app)
        @app = app
      end

      def call(env)
        request = ::Rack::Request.new(env)

        request.site = Circuit.site_store.get(request.host)
        unless request.site
          # TODO custom 404 page for site not found
          return [404, {}, ["Not Found"]]
        end

        @app.call(request.env)
      end
    end
  end
end
