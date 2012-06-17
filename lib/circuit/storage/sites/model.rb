require 'active_support/concern'
require 'active_model/validations'
require 'circuit/validators'

module Circuit
  module Storage
    module Sites
      # @abstract include into a Class or Module to setup the necessary methods
      # for a Site model
      module Model
        # Validations for Site models
        # * validates the host's format and presence
        # * validates the aliases' formats
        # @see Circuit::Validators::DomainValidator
        # @see Circuit::Validators::DomainArrayValidator
        # @abstract include into a Site class or Module to add the Validations
        module Validations
          extend ActiveSupport::Concern
          include ActiveModel::Validations

          included do
            validates :host, :presence => true, :domain => true
            validates :aliases, :domain_array => true
          end
        end
      end
    end
  end
end
