require 'spec_helper'
require 'stringio'

describe Circuit do
  include SpecHelpers::LoggerHelpers
  include SpecHelpers::StoresCleaner

  context 'object' do
    subject { lambda { Circuit } }
    it { should_not raise_error }
  end

  context "logger" do
    context "default" do
      subject { Circuit.logger }
      it { should be_instance_of(::Logger) }
    end

    context "set" do
      before &:clean_logger!
      let(:new_logger) { ::Logger.new(StringIO.new) }
      before { Circuit.logger = new_logger }
      subject { Circuit.logger }
      it { should == new_logger }
    end

    context "change" do
      let(:new_logger) { ::Logger.new(StringIO.new) }
      before { Circuit.logger = new_logger }
      subject { Circuit.logger }
      it { should == new_logger }
      it { should_not == default_logger }
    end
  end

  context "site store" do
    let(:klass) { $mongo_tests ? Circuit::Storage::Sites::MongoidStore : Circuit::Storage::Sites::MemoryStore }

    context "get" do
      let(:mock_instance) { mock() }
      before { Circuit::Storage::Sites.expects(:instance).returns(mock_instance) }
      after { Circuit::Storage::Sites.unstub(:instance) }
      it { Circuit.site_store.should == mock_instance}
    end

    context "not set" do
      it do
        expect { Circuit.site_store }.
          to raise_error(Circuit::Storage::InstanceUndefinedError, "Storage instance is undefined.")
      end
      it { expect { Circuit::Site }.to raise_error(NameError) }
    end

    context "set by class" do
      before { Circuit.set_site_store klass }
      it { Circuit.site_store.should be_instance_of klass }
    end

    context "set by instance" do
      let(:instance) { klass.new }
      before { Circuit.set_site_store instance }
      it { Circuit.site_store.should == instance }
    end

    context "set by symbol" do
      before { Circuit.set_site_store($mongo_tests ? :mongoid_store : :memory_store) }
      it { Circuit.site_store.should be_instance_of(klass) }
    end

    context "set wrong type" do
      it do
        expect { Circuit.set_site_store Object.new }.
          to raise_error(ArgumentError, "Unexpected type for storage instance: Object")
      end
    end
  end

  context "node store" do
    let(:klass) { $mongo_tests ? Circuit::Storage::Nodes::MongoidStore : Circuit::Storage::Nodes::MemoryStore }

    context "get" do
      let(:mock_instance) { mock() }
      before { Circuit::Storage::Nodes.expects(:instance).returns(mock_instance) }
      after { Circuit::Storage::Nodes.unstub(:instance) }
      it { Circuit.node_store.should == mock_instance}
    end

    context "not set" do
      it do
        expect { Circuit.node_store }.
          to raise_error(Circuit::Storage::InstanceUndefinedError, "Storage instance is undefined.")
      end
      it { expect { Circuit::Node }.to raise_error(NameError) }
    end

    context "set by class" do
      before { Circuit.set_node_store klass }
      it { Circuit.node_store.should be_instance_of klass }
    end

    context "set by instance" do
      let(:instance) { klass.new }
      before { Circuit.set_node_store instance }
      it { Circuit.node_store.should == instance }
    end

    context "set by symbol" do
      before { Circuit.set_node_store($mongo_tests ? :mongoid_store : :memory_store) }
      it { Circuit.node_store.should be_instance_of klass }
    end

    context "set wrong type" do
      it do
        expect { Circuit.set_node_store Object.new }.
          to raise_error(ArgumentError, "Unexpected type for storage instance: Object")
      end
    end
  end

  context "set cru_path" do
    context "by String" do
      before { Circuit.cru_path = "foo/bar" }
      it { Circuit.cru_path.should == Pathname.new("foo/bar") }
    end

    context "by Pathname" do
      before { Circuit.cru_path = Pathname.new("foo/bar") }
      it { Circuit.cru_path.should == Pathname.new("foo/bar") }
    end
  end

  describe "vendor_path" do
    it { Circuit.vendor_path.should == Pathname.new(__FILE__).expand_path.dirname.join("..", "..", "vendor")}
  end
end
