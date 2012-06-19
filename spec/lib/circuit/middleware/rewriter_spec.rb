require 'spec_helper'

describe Circuit::Middleware::Rewriter do
  include SpecHelpers::LoggerHelpers
  let(:request) { mock_request() } # http://www.example.com/foo/bar/baz

  def self.run_app(&block)
    before do
      @response = ::Rack::Builder.new do
        use Circuit::Middleware::Rewriter, &block
        run lambda { |env| [ 200, {}, %w[SCRIPT_NAME PATH_INFO].collect {|k| env[k]} ] }
      end.to_app.call(mock_request.env)
    end
    subject { @response }
  end

  context "should be able to not rewrite" do
    run_app { |*args| args }
    subject { @response }
    it { should == [ 200, {}, ["", "/foo/bar/baz"] ] }

    context "logger" do
      subject { logger_output }
      it { should be_blank }
    end
  end

  context "rewrite script_name and path_info" do
    run_app do |script_name, path_info|
      ["/site/5#{script_name}", path_info+"/1"]
    end
    it { should == [ 200, {}, %w[/site/5 /foo/bar/baz/1] ] }

    context "logger" do
      subject { logger_output }
      it { should == "[CIRCUIT] Rewriting: '/foo/bar/baz'->'/site/5/foo/bar/baz/1'\n" }
    end
  end

  context "rewrite script_name and not path_info" do
    run_app do |script_name, path_info|
      ["/site/5#{script_name}", path_info]
    end
    it { should == [ 200, {}, %w[/site/5 /foo/bar/baz] ] }

    context "logger" do
      subject { logger_output }
      it { should == "[CIRCUIT] Rewriting: '/foo/bar/baz'->'/site/5/foo/bar/baz'\n" }
    end
  end

  context "rewrite path_info and not script_name" do
    run_app do |script_name, path_info|
      [script_name, path_info+"/1"]
    end
    it { should == [ 200, {}, ["", "/foo/bar/baz/1"] ] }

    context "logger" do
      subject { logger_output }
      it { should == "[CIRCUIT] Rewriting: '/foo/bar/baz'->'/foo/bar/baz/1'\n" }
    end
  end

  context "should catch and log rewriter errors" do
    run_app do |*args|
      raise Circuit::Middleware::RewriteError, "an error occurred"
    end
    it { should == [ 200, {}, ["", "/foo/bar/baz"] ] }

    context "logger" do
      subject { logger_output.split(/\n/) }
      it { should have(2).lines }
      it { subject.first.should == "[CIRCUIT] Rewrite Error: an error occurred" }
      it "second line should have the backtrace" do
        subject.last.should match(/\A\s+(.+)#{Regexp.quote("rewriter_spec.rb")}\:(\d+)(\:in|$)/)
      end
    end
  end
end
