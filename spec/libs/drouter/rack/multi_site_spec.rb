require 'spec_helper'

describe Circuit::Rack::MultiSite do
  include Rack::Test::Methods
  include SpecHelpers::MultiSiteHelper

  def app
    Rack::Builder.app do
      use Circuit::Rack::MultiSite
      run Proc.new {|env| [200, {}, ["ok"]] }
    end
  end

  context 'GET example.com' do
    before do
      get "http://#{site.host}/"
    end

    context "status" do
      subject { last_response.status }
      it { should == 200 }
    end
  end

  context "GET baddomain.com" do
    before do
      get "http://baddomain.com/"
    end

    subject { last_response }
    it { subject.status.should == 404 }
    it { subject.body.should == "Not Found"}
  end
end
