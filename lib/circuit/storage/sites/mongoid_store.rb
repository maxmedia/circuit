module Circuit
  module Storage
    module Sites
      class MongoidStore < BaseStore
        def get(host)
          sites = Circuit::Site.any_of({host: host}, {aliases: host}).all
          if sites.length > 1
            raise MultipleFoundError, "Multiple sites found"
          end
          sites.first
        end

        class Site
          include Model
          include Model::Validations
          include Mongoid::Document

          store_in collection: "circuit_sites"

          field :host, type: String
          field :aliases, type: Array

          has_one :route, class_name: "Circuit::Tree",
                          inverse_of: :site
        end
      end
    end
  end
end
