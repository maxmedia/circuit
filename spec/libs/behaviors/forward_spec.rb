require 'spec_helper'

describe Behaviors::Forward do
  include Rack::Test::Methods
  include SpecHelpers::MultiSiteHelper

  def app
    stub_app_with_circuit_site setup_site!(root.site, Behaviors::Forward)
  end

  context 'GET /' do

    context "example 1" do
      get "/"
      subject { last_response.body }
      it { should == "downstream /" }
    end

    context "example 2" do
      get "/another-path"
      subject { last_response.body }
      it { should == "downstream /another-path" }
    end

  end
end
