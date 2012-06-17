require 'spec_helper'

describe Circuit::Storage do
  include SpecHelpers::StoresCleaner

  context "undefined site store" do
    it do
      expect { Circuit.site_store }.
        to raise_error(Circuit::Storage::InstanceUndefinedError, "Storage instance is undefined.")
    end
  end

  context "undefined node store" do
    it do
      expect { Circuit.node_store }.
        to raise_error(Circuit::Storage::InstanceUndefinedError, "Storage instance is undefined.")
    end
  end

end
