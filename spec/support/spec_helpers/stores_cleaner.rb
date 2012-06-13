require 'active_support/concern'

module SpecHelpers
  module StoresCleaner
    extend ActiveSupport::Concern
    include CircuitBlueprints

    included do
      around :each do |example|
        orig_site_store = Circuit::Storage::Sites.instance_variable_get(:@instance)
        orig_tree_store = Circuit::Storage::Trees.instance_variable_get(:@instance)
        clear_storage

        if @storage
          Circuit.set_site_store @storage
          Circuit.set_tree_store @storage
          ensure_blueprints
        end

        example.run

        clear_storage
        silence_warnings do
          Circuit.set_site_store orig_site_store
          Circuit.set_tree_store orig_tree_store
        end
        ensure_blueprints
      end
    end

    module ClassMethods
      def use_storage(val)
        before(:all) { @storage = val }
      end
    end

    private

    def clear_storage
      Circuit::Storage::Sites.instance_variable_set(:@instance, nil)
      Circuit::Storage::Trees.instance_variable_set(:@instance, nil)
      Circuit.send(:remove_const, :Site) rescue NameError
      Circuit.send(:remove_const, :Tree) rescue NameError
    end
  end
end
