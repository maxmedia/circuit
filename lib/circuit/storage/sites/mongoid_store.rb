require 'active_support/concern'

module Circuit
  module Storage
    module Sites
      # Concrete site store for Mongoid
      class MongoidStore < BaseStore
        # @raise MultipleFoundError if multiple sites are found for the given `host`
        # @param [String] host to find
        # @return [Model] site
        def get(host)
          sites = site_klass.any_of({:host => host}, {:aliases => host}).all
          if sites.length > 1
            raise MultipleFoundError, "Multiple sites found"
          end
          sites.first
        end

        # Mongoid Site module
        #
        # *Remember to setup your `has_one :root` association to point to the root of the tree.*
        module Site
          extend ActiveSupport::Concern

          # @!attribute host
          #   @return [String] domain name

          # @!attribute aliases
          #   @return [Array<String>] array of domain name aliases

          # *Setup #root as a `has_one` association in your concrete Site class*
          # @!attribute root
          #   @return [Nodes::Model] root node

          included do
            MongoidStore.site_klass = self
            field :host, :type => String
            field :aliases, :type => Array
          end

          include Model
          include Model::Validations
          include Mongoid::Document
        end
      end
    end
  end
end
