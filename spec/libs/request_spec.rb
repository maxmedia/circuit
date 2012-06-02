require 'spec_helper'

describe Circuit::Rack::Request do
  def mock_request(env={})
    Rack::Request.new(Rack::MockRequest.env_for("http://www.example.com/foo/bar", env))
  end

  context "Rack::Request should have module" do
    it { ::Rack::Request.included_modules.should include(::Circuit::Rack::Request) }
  end

  context "get site" do
    let(:site) { mock() }
    subject { mock_request Circuit::Rack::Request::ENV_SITE => site }
    it { subject.site.should == site }
  end

  context "set site" do
    let(:site) { mock() }
    subject { mock_request.tap { |r| r.site = site } }
    it { subject.site.should == site }
  end

  context "get route" do
    let(:route) { mock() }
    subject { mock_request Circuit::Rack::Request::ENV_ROUTE => route }
    it { subject.route.should == route }
  end

  context "set route" do
    let(:route) { mock() }
    subject { mock_request.tap { |r| r.route = route } }
    it { subject.route.should == route }
  end

  context "get route_path" do
    let(:route_path) { mock() }
    subject { mock_request Circuit::Rack::Request::ENV_ROUTE_PATH => route_path }
    it { subject.route_path.should == route_path }
  end

  context "set route_path" do
    let(:route_path) { mock() }
    subject { mock_request.tap { |r| r.route_path = route_path } }
    it { subject.route_path.should == route_path }
  end

  context "get original_path" do
    let(:original_path) { mock() }
    subject { mock_request Circuit::Rack::Request::ENV_ORIGINAL_PATH => original_path }
    it { subject.original_path.should == original_path }
  end

  context "set original_path" do
    let(:original_path) { mock() }
    subject { mock_request.tap { |r| r.original_path = original_path } }
    it { subject.original_path.should == original_path }
  end

  context "set path" do
    let(:path) { "/fooey" }
    subject { mock_request.tap {|r| r.path = path } }
    it { subject.path.should == path }
    it { subject.env["PATH_INFO"].should == path }
    it { subject.env["SCRIPT_NAME"].should == "" }
  end

  context "path_segments" do
    subject { mock_request }
    it { subject.path_segments.should == %w[foo bar] }
  end

  context "path_segments with blanks and double slashes" do
    subject { mock_request.tap { |r| r.path = "/foo//bar/fooey///" } }
    it { subject.path_segments.should == %w[foo bar fooey] }
  end
end
