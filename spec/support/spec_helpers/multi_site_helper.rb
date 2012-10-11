require 'active_support/concern'
require File.expand_path("../base_models", __FILE__)

module SpecHelpers
  module MultiSiteHelper
    extend ActiveSupport::Concern
    include BaseModels

    def setup_site!(site, behavior)
      site.root.behavior = behavior
      site.root.save!
      site
    end

    def stub_app_with_circuit_site(my_site, middleware_klass=set_site_middleware)
      Rack::Builder.app do
        use middleware_klass, my_site
        use Circuit::Rack::Behavioral
        run Proc.new {|env| [404, {}, ["downstream #{env['PATH_INFO']}"]] }
      end
    end

    def set_site_middleware()
      (Class.new do
        def initialize(app, site)
          @app  = app
          @site = site
        end

        def call(env)
          request = Rack::Request.new(env)
          request.site = @site
          @app.call(request.env)
        end
      end)
    end

    module ClassMethods

      def get(*args)
        before do
          super(*args) if respond_to?(:super)
          get *args
        end
      end

    end
  end
end
