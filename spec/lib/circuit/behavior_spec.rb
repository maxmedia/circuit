require 'spec_helper'

describe Circuit::Behavior do
  class Middleware1
    def initialize(app); end
  end
  class Middleware2
    def initialize(app); end
  end
  class Middleware3
    def initialize(app); end
  end

  class BaseClass
    include Circuit::Behavior
    use Middleware1
    use Middleware2
  end

  class InheritedClass < BaseClass
    use Middleware3
  end

  module NoBuilderBehavior
    include Circuit::Behavior
  end

  let(:base_class) { BaseClass }
  let(:inherited_class) { InheritedClass }
  subject { BaseClass }

  it { lambda{Circuit::Behavior}.should_not raise_error }
  it { lambda{ subject }.should_not raise_error }
  it { subject.builder.should be_true }

  context 'is listed in ancestors' do
    subject { base_class.ancestors }
    it { should include Circuit::Behavior }
  end

  context 'is listed in inherited ancestors' do
    subject { inherited_class.ancestors }
    it { should include Circuit::Behavior }
  end

  context 'when mixed class is configured' do
    subject { base_class.builder.instance_variable_get(:@use) }
    it { subject.each { |u| u.should be_instance_of(Proc) } }
    it { should have(2).procs}
    it { subject[0].call(Object.new).class.should == Middleware1 }
    it { subject[1].call(Object.new).class.should == Middleware2 }
  end

  context 'inherited stack is configured properly' do
    subject { inherited_class.builder.instance_variable_get(:@use) }
    it { subject.each { |u| u.should be_instance_of(Proc) } }
    it { should have(3).procs}
    it { subject[0].call(Object.new).class.should == Middleware1 }
    it { subject[1].call(Object.new).class.should == Middleware2 }
    it { subject[2].call(Object.new).class.should == Middleware3 }
  end

  context "without a builder" do
    subject { NoBuilderBehavior }
    it { subject.builder?.should be_false }
  end

  context "without a cru path" do
    before do
      @prev_cru_path = Circuit.cru_path
      Circuit.instance_variable_set(:@cru_path, nil)
      NoBuilderBehavior.instance_variable_set(:@cru_path, nil)
    end
    subject { NoBuilderBehavior }
    it { subject.builder?.should be_false }
    it do
      expect { subject.cru_path }.
        to raise_error(Circuit::Behavior::RackupPathError, 
                       "Rackup path cannot be determined for NoBuilderBehavior")
    end
    after { Circuit.cru_path = @prev_cru_path }
  end

  describe "get constants" do
    context "already loaded" do
      before { ChangePath }
      subject { Circuit::Behavior.get("ChangePath") }
      it { should == lambda{ChangePath}.call }
      it { should have_module(Circuit::Behavior) }
      it { subject.to_s.should == "ChangePath" }
      it { subject.builder?.should be_true }
      it "should not dynamically set a constant" do
        Object.expects(:const_set).never
        subject
      end
      after { Object.unstub(:const_set) }
    end

    context "load from .cru" do
      before { Object.send(:remove_const, :RenderOk) if Object.const_defined?(:RenderOk) }
      subject { Circuit::Behavior.get("RenderOk") }
      it { should == lambda{RenderOk}.call }
      it { should have_module(Circuit::Behavior) }
      it { subject.to_s.should == "RenderOk" }
      it { subject.builder?.should be_true }
      it "should dynamically set a constant" do
        Object.expects(:const_set).once
        subject
      end
      after { Object.unstub(:const_set) }
    end
  end
end
