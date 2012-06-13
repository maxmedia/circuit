require 'spec_helper'

describe Behaviors::MountByFragmentOrRemap do
  include Rack::Test::Methods
  include SpecHelpers::MultiSiteHelper

  def app
    stub_app_with_circuit_site setup_site!(root.site, Behaviors::MountByFragmentOrRemap)
  end

  context 'GET /' do
    subject { last_response.body }
    get "/"

    context "status" do
      it { should == "downstream /" }
    end
  end

  context 'GET /test' do
    before do
      Circuit::Tree.any_instance.expects(:find_child_by_fragment).
        with("test").at_least_once.returns(route_lookup)

      get "/test"
    end

    subject { last_response.body }

    context "when found" do
      let(:route_lookup) { Circuit::Tree.make behavior: ::Behaviors::RenderOK }
      it { should == "ok" }
    end

    context "when not found" do
      let(:route_lookup) { nil }
      it { should == "downstream /test" }
    end
  end

end
