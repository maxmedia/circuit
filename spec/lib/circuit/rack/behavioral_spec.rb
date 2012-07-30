require 'spec_helper'

describe Circuit::Rack::Behavioral do
  include Rack::Test::Methods
  include SpecHelpers::MultiSiteHelper

  class RenderMyMiddlewareBehavior
    include ::Circuit::Behavior

    use(Class.new do
      def initialize(app)
        @app = app
      end

      def call(env)
        [200, {"Content-Type" => "test/html"}, ["RenderMyMiddlewareBehavior"]]
      end
    end)
  end

  def app
    stub_app_with_circuit_site setup_site!(root.site, RenderMyMiddlewareBehavior)
  end

  context 'GET /' do
    get "/"

    context "status" do
      subject { last_response.body }
      it { should include("RenderMyMiddlewareBehavior") }
    end
  end

  context 'GET / for site with no root' do
    def app
      stub_app_with_circuit_site dup_site_1
    end

    it "should return 404 Not Found" do
      get "/"
      last_response.status.should == 404
      last_response.body.should == "Not Found"
    end
  end

  context "GET / without site" do
    def no_site_middleware
      (Class.new do
        def initialize(app, site=nil) @app = app; end
        def call(env) @app.call(env); end
      end)
    end

    def app
      stub_app_with_circuit_site nil, no_site_middleware
    end

    it "should raise a missing site error" do
      expect { get "/" }.to raise_error(Circuit::Rack::MissingSiteError, "Rack variable rack.circuit.site is missing")
    end
  end
end
