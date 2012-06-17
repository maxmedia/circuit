require 'spec_helper'

describe Circuit::Storage::Sites do
  include SpecHelpers::StoresCleaner
  include SpecHelpers::BaseModels

  describe Circuit::Storage::Sites::BaseStore do
    context "unimplemented store" do
      class Circuit::Storage::Sites::UnimplementedStore < Circuit::Storage::Sites::BaseStore
      end

      subject { Circuit::Storage::Sites::UnimplementedStore.new }

      it do
        expect { subject.get("foo") }.
          to raise_error(Circuit::Storage::Sites::UnimplementedError, "Circuit::Storage::Sites::UnimplementedStore#get not implemented.")
      end

      it do
        expect { subject.get!("foo") }.
          to raise_error(Circuit::Storage::Sites::UnimplementedError, "Circuit::Storage::Sites::UnimplementedStore#get not implemented.")
      end
    end

    context "empty store" do
      class Circuit::Storage::Sites::EmptyStore < Circuit::Storage::Sites::BaseStore
        def get(host) nil; end
      end

      subject { Circuit::Storage::Sites::EmptyStore.new }

      it { subject.get("foo").should be_nil }

      it do
        expect { subject.get!("foo").
          to raise_error(Circuit::Storage::Sites::NotFoundError, "Host not found")
        }
      end
    end
  end

  describe Circuit::Storage::Sites::MemoryStore do
    use_storage :memory_store
    let!(:store) { :memory_store }
    include_examples "site store"

    describe Circuit::Storage::Sites::MemoryStore::Site do
      subject { site }
      it { should have_attribute(:host) }
      it { should have_attribute(:aliases) }
      it { should have_attribute(:route) }
    end
  end

  describe "Circuit::Storage::Sites::MongoidStore", :if => $mongo_tests do
    use_storage :mongoid_store
    let!(:store) { :mongoid_store }
    include_examples "site store"
  end
end
