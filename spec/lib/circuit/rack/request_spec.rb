require 'spec_helper'

describe Circuit::Rack::Request do
  context "Rack::Request should have module" do
    it { ::Rack::Request.included_modules.should include(::Circuit::Rack::Request) }
  end

  describe "site" do
    let(:site) { mock() }

    context "get" do
      subject { mock_request(Circuit::Rack::Request::ENV_SITE => site).site }
      it { should == site }
    end

    context "set" do
      subject { mock_request.tap { |r| r.site = site } }
      it { subject.site.should == site }
      it { subject.env[Circuit::Rack::Request::ENV_SITE].should == site }
    end
  end

  describe "path segments" do
    context "splits by slashes" do
      subject { mock_request.path_segments }
      it { should == [nil]+%w[foo bar baz] }
    end

    context "path_segments with blanks and double slashes" do
      subject { mock_request(path: "/foo//bar/baz///").path_segments }
      it { should == [nil]+%w[foo bar baz] }
    end

    context "class method" do
      it do
        ::Rack::Request.expects(:path_segments).once.with("/foo/bar/baz")
        mock_request.path_segments
      end
      after { ::Rack::Request.unstub(:path_segments) }
    end
  end

  describe "route" do
    let(:route) { mock() }

    context "none" do
      subject { mock_request.route }
      it { should be_nil }
    end

    context "get" do
      subject { mock_request(Circuit::Rack::Request::ENV_ROUTE => route).route }
      it { should == route }
    end

    context "set" do
      let(:path) { "/foo/bar/baz" }
      let(:route) { mock(:last => mock(:path => path), :length => 4) }
      subject { mock_request.tap { |r| r.route = route } }
      it { subject.route.should == route }
      it { subject.env["SCRIPT_NAME"].should == "/foo/bar/baz" }
      it { subject.env["PATH_INFO"].should == "" }
      it { subject.path.should == "/foo/bar/baz" }
      it { subject.circuit_originals["SCRIPT_NAME"].should == "" }
      it { subject.circuit_originals["PATH_INFO"].should == "/foo/bar/baz" }
    end

    context "set partial path" do
      let(:path) { "/foo/bar" }
      let(:route) { mock(:last => mock(:path => path), :length => 3) }
      subject { mock_request.tap { |r| r.route = route } }
      it { subject.route.should == route }
      it { subject.env["SCRIPT_NAME"].should == "/foo/bar" }
      it { subject.env["PATH_INFO"].should == "/baz" }
      it { subject.path.should == "/foo/bar/baz" }
      it { subject.circuit_originals["SCRIPT_NAME"].should == "" }
      it { subject.circuit_originals["PATH_INFO"].should == "/foo/bar/baz" }
    end
  end
end
