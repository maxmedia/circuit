require 'active_support/concern'

module Circuit
  module Storage
    module Sites
      # Concrete site store for memory
      class MemoryStore < BaseStore
        # @raise MultipleFoundError if multiple sites are found for the given `host`
        # @param [String] host to find
        # @return [Model] site
        def get(host)
          sites = site_klass.all.select {|s| s.host == host or s.aliases.include?(host)}
          if sites.length > 1
            raise MultipleFoundError, "Multiple sites found"
          end
          sites.first
        end

        # In-memory Site module
        module Site
          extend ActiveSupport::Concern

          # @!attribute host
          #   @return [String] domain name

          # @!attribute aliases
          #   @return [Array<String>] array of domain name aliases

          # @!attribute root
          #   @return [Nodes::Model] root node

          included do
            MemoryStore.site_klass = self
            setup_attributes :host, :aliases, :root
          end

          include Circuit::Storage::MemoryModel
          include Circuit::Storage::Sites::Model
          include Circuit::Storage::Sites::Model::Validations

          def initialize(opts={})
            memory_model_setup
            self.attributes = opts
            self.aliases ||= Array.new
          end

          # Save the Site to memory
          # @return [Boolean] `true` if the Site was saved
          def save
            return false if invalid?
            unless persisted?
              self.class.all << self
            end
            persisted!
          end
        end
      end
    end
  end
end
