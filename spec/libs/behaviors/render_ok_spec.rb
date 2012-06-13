require 'spec_helper'

describe Behaviors::RenderOK do
  include Rack::Test::Methods
  include SpecHelpers::MultiSiteHelper

  def app
    stub_app_with_circuit_site setup_site!(root.site, Behaviors::RenderOK)
  end

  context 'GET /' do
    get "/"

    context "status" do
      subject { last_response }
      it { should be_ok }
    end

  end

end
