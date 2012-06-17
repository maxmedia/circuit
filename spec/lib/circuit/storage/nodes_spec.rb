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
end
