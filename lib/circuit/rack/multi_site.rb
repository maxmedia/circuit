module Circuit
  module Rack
    # Finds the Circuit::Site for the request.  Returns a 404 if the site is not found.
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
