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

    it do
      expect { get "/" }.to raise_error(Circuit::Rack::MissingSiteError, "Rack variable rack.circuit.site is missing")
    end
  end

  context 'rewrite_with_behavior!' do
    let(:request)    { ::Rack::Request.new(Rack::MockRequest.env_for("/")) }
    let(:behavior)   { mock() }
    let(:behavioral) { Circuit::Rack::Behavioral.new('_') }
    subject { behavioral.rewrite_with_behavior! behavior, request }

    context 'when unset' do
      before do
        behavior.expects(:respond_to?).with(:rewrite!).once.returns(false)
        behavior.expects(:rewrite!).never
      end

      it { should == :rewrite_not_configured }
    end

    context 'rewrite_with_behavior!' do
      before do
        behavior.expects(:respond_to?).with(:rewrite!).once.returns(true)
        behavior.expects(:rewrite!).with(request).once
      end

      it { should == :rewritten }
    end

    context 'when raised ::Circuit::Behavior::RewriteException' do
      before do
        behavior.expects(:respond_to?).with(:rewrite!).once.returns(true)
        behavior.expects(:rewrite!).raises(::Circuit::Behavior::RewriteException)
      end

      it { should == :rewrite_failed }
    end

  end

  context 'GET / in rewrite' do
    class RewritePathInfoToFoobar
      include ::Circuit::Behavior

      def self.rewrite!(request)
        request.path = "/foobar"
      end
    end

    def app
      stub_app_with_circuit_site setup_site!(root.site, RewritePathInfoToFoobar)
    end

    context "example 1" do
      get "/"
      subject { last_response.body }
      it { should == "downstream /foobar" }
    end
  end
end
