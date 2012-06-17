module Circuit
  module Storage
    module Sites
      # Concrete site store for Mongoid
      class MongoidStore < BaseStore
        # @raise MultipleFoundError if multiple sites are found for the given `host`
        # @param [String] host to find
        # @return [Model] site
        def get(host)
          sites = Circuit::Site.any_of({host: host}, {aliases: host}).all
          if sites.length > 1
            raise MultipleFoundError, "Multiple sites found"
          end
          sites.first
        end

        # Concrete Mongoid Site class
        class Site
          include Model
          include Model::Validations
          include Mongoid::Document

          store_in collection: "circuit_sites"

          field :host, type: String
          field :aliases, type: Array

          # @!attribute host
          #   @return [String] domain name

          # @!attribute aliases
          #   @return [Array<String>] array of domain name aliases

          # @!attribute route
          #   @return [Nodes::Model] root node

          has_one :route, class_name: "Circuit::Node",
                          inverse_of: :site
        end
      end
    end
  end
end
