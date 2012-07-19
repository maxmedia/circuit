require 'spec_helper'

describe Circuit::Storage::Nodes do
  include SpecHelpers::StoresCleaner
  include SpecHelpers::BaseModels

  describe Circuit::Storage::Nodes::BaseStore do
    context "unimplemented store" do
      class Circuit::Storage::Nodes::UnimplementedStore < Circuit::Storage::Nodes::BaseStore
      end

      subject { Circuit::Storage::Nodes::UnimplementedStore.new }

      it do
        expect { subject.get("foo", "bar") }.
          to raise_error(Circuit::Storage::Nodes::UnimplementedError, "Circuit::Storage::Nodes::UnimplementedStore#get not implemented.")
      end

      it do
        expect { subject.get!("foo", "bar") }.
          to raise_error(Circuit::Storage::Nodes::UnimplementedError, "Circuit::Storage::Nodes::UnimplementedStore#get not implemented.")
      end
    end

    context "empty store" do
      class Circuit::Storage::Nodes::EmptyStore < Circuit::Storage::Nodes::BaseStore
        def get(site, path) nil; end
      end

      subject { Circuit::Storage::Nodes::EmptyStore.new }

      it { subject.get("foo", "bar").should be_nil }

      it do
        expect { subject.get!("foo", "bar").
          to raise_error(Circuit::Storage::Nodes::NotFoundError, "Host not found")
        }
      end
    end
  end

  describe Circuit::Storage::Nodes::MemoryStore do
    let(:site_class) { ::Site }
    let(:node_class) { ::RouteNode }
    use_storage :memory_store
    let!(:store) { :memory_store }
    include_examples "node store"

    describe Circuit::Storage::Nodes::MemoryStore::Node do
      subject { child }
      it { should have_attribute(:slug) }
      it { should have_attribute(:behavior_klass) }
      it { should have_attribute(:site) }
      it { should have_attribute(:parent) }
      it { should have_attribute(:children) }
    end
  end

  describe "Circuit::Storage::Nodes::MongoidStore", :if => $mongo_tests do
    use_storage :mongoid_store
    let!(:store) { :mongoid_store }
    include_examples "node store"
  end

  describe "subclasses in mongo", :if => $mongo_tests do
    use_storage :mongoid_store

    if $mongo_tests
      class SubclassA < MongoidRouteNode; end
      class SubclassB < MongoidRouteNode; end
      class SubclassC < SubclassA; end
      class SubclassD < SubclassC; end
    end

    before do
      root_ = ::MongoidRouteNode.create(:site => site, :behavior_klass => "RenderOk")
      SubclassA.create(:parent => root_, :slug => "foo", :behavior_klass => "RenderOk")
      SubclassB.create(:parent => root_, :slug => "bar", :behavior_klass => "RenderOk")
      SubclassC.create(:parent => root_, :slug => "baz", :behavior_klass => "RenderOk")
      SubclassD.create(:parent => root_, :slug => "wow", :behavior_klass => "RenderOk")
      SubclassA.create(:site => site_1, :behavior_klass => "RenderOk")
    end

    it { site.root.class.should include(Circuit::Storage::Nodes::MongoidStore::Node) }
    it { site.root.should be_instance_of(::MongoidRouteNode) }
    it { Circuit.node_store.get(site, "/").last.class.should include(Circuit::Storage::Nodes::MongoidStore::Node) }
    it { Circuit.node_store.get(site, "/").last.should be_instance_of(::MongoidRouteNode) }
    it { Circuit.node_store.get(site, "/foo").last.should be_instance_of(SubclassA) }
    it { Circuit.node_store.get(site, "/bar").last.should be_instance_of(SubclassB) }
    it { Circuit.node_store.get(site, "/baz").last.should be_instance_of(SubclassC) }
    it { Circuit.node_store.get(site, "/wow").last.should be_instance_of(SubclassD) }
    it { Circuit.node_store.get(site_1, "/").last.should be_instance_of(SubclassA) }
    it { SubclassA.where(:slug => "foo").first.should be_instance_of(SubclassA) }
    it { SubclassA.where(:slug => "baz").first.should be_instance_of(SubclassC) }
    it { SubclassC.where(:slug => "foo").first.should be_nil }
    it { SubclassC.where(:slug => "baz").first.should be_instance_of(SubclassC) }
  end
end
