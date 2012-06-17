require 'spec_helper'

describe Circuit::Railtie do
  context "middlewares" do
    subject { Rails.application.config.middleware }
    it { subject[0].klass.should == Circuit::Rack::MultiSite }
    it { subject[1].klass.should == Circuit::Rack::Behavioral }
  end

  context "default cru_path" do
    subject { Circuit.cru_path }
    it { should == Rails.root.join("app", "behaviors") }
  end

  context "application paths" do
    subject { Rails.application.config.paths.all_paths }
    it { should include(["app/behaviors"]) }
  end

  context "eager load paths" do
    subject { Rails.application.config.paths.eager_load }
    it { should include(Circuit.cru_path.to_s) }
    it do
      Dir.glob(Circuit.cru_path.join("**", "*.rb")).each do |path|
        subject.should include(path)
      end
    end
  end

  context "logger" do
    subject { Circuit.logger }
    it { should equal(Rails.logger) }
  end
end