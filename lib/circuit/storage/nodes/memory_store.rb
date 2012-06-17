module Circuit
  module Storage
    module Nodes
      class MemoryStore < BaseStore
        def get(site, path)
          find_nodes_for_path(site.route, path)
        rescue NotFoundError
          return nil
        end

        class Node
          include Circuit::Storage::MemoryModel
          setup_attributes :slug, :behavior_klass, :site, :parent, :children

          include Circuit::Storage::Nodes::Model
          include Circuit::Storage::Nodes::Model::Validations

          def initialize(opts={})
            memory_model_setup
            behavior = opts.delete(:behavior) || opts.delete("behavior")
            self.attributes = opts
            self.slug = opts[:slug]
            self.behavior = behavior if behavior
            self.children ||= Array.new
          end

          def save
            return false if invalid?
            unless persisted?
              self.site.route = self if self.site
              self.parent.children << self if self.parent
              self.children.each {|c| c.parent = self}
              self.class.all << self
            end
            persisted!
          end
        end
      end
    end
  end
end
