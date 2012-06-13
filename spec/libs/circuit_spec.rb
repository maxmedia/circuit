require 'spec_helper'
require 'stringio'

describe Circuit do
  include SpecHelpers::LoggerCleaner
  include SpecHelpers::StoresCleaner

  context 'object' do
    subject { -> { Circuit } }
    it { should_not raise_error }
  end

  context "logger" do
    context "default" do
      subject { Circuit.logger }
      it { should be_instance_of(::Logger) }
    end

    context "set" do
      let(:new_logger) { ::Logger.new(StringIO.new) }
      before { Circuit.logger = new_logger }
      it { Circuit.logger.should == new_logger }
    end

    context "change" do
      let(:new_logger) { ::Logger.new(StringIO.new) }
      before do
        @default_logger = Circuit.logger
        Circuit.logger = new_logger
      end
      it { @default_logger.should_not == new_logger}
      it { Circuit.logger.should == new_logger }
      it { Circuit.logger.should_not == @default_logger }
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
      it { Circuit::Site.should == klass.const_get(:Site) }
    end

    context "set by instance" do
      let(:instance) { klass.new }
      before { Circuit.set_site_store instance }
      it { Circuit.site_store.should == instance }
      it { Circuit::Site.should == klass.const_get(:Site) }
    end

    context "set by symbol" do
      before { Circuit.set_site_store($mongo_tests ? :mongoid_store : :memory_store) }
      it { Circuit.site_store.should be_instance_of(klass) }
      it { Circuit::Site.should == klass.const_get(:Site) }
    end

    context "set wrong type" do
      it do
        expect { Circuit.set_site_store Object.new }.
          to raise_error(ArgumentError, "Unexpected type for storage instance: Object")
      end
    end

    context "set with no Site class" do
      it do
        expect { Circuit.set_site_store Object }.
          to raise_error(ArgumentError, "Cannot determine a Site or Tree class for storage type: Object")
      end
    end
  end

  context "tree store" do
    let(:klass) { $mongo_tests ? Circuit::Storage::Trees::MongoidStore : Circuit::Storage::Trees::MemoryStore }

    context "get" do
      let(:mock_instance) { mock() }
      before { Circuit::Storage::Trees.expects(:instance).returns(mock_instance) }
      after { Circuit::Storage::Trees.unstub(:instance) }
      it { Circuit.tree_store.should == mock_instance}
    end

    context "not set" do
      it do
        expect { Circuit.tree_store }.
          to raise_error(Circuit::Storage::InstanceUndefinedError, "Storage instance is undefined.")
      end
      it { expect { Circuit::Tree }.to raise_error(NameError) }
    end

    context "set by class" do
      before { Circuit.set_tree_store klass }
      it { Circuit.tree_store.should be_instance_of klass }
      it { Circuit::Tree.should == klass.const_get(:Tree) }
    end

    context "set by instance" do
      let(:instance) { klass.new }
      before { Circuit.set_tree_store instance }
      it { Circuit.tree_store.should == instance }
      it { Circuit::Tree.should == klass.const_get(:Tree) }
    end

    context "set by symbol" do
      before { Circuit.set_tree_store($mongo_tests ? :mongoid_store : :memory_store) }
      it { Circuit.tree_store.should be_instance_of klass }
      it { Circuit::Tree.should == klass.const_get(:Tree) }
    end

    context "set wrong type" do
      it do
        expect { Circuit.set_tree_store Object.new }.
          to raise_error(ArgumentError, "Unexpected type for storage instance: Object")
      end
    end

    context "set with no Tree class" do
      it do
        expect { Circuit.set_tree_store Object }.
          to raise_error(ArgumentError, "Cannot determine a Site or Tree class for storage type: Object")
      end
    end
  end
end
