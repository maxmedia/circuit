require 'active_support/concern'
require 'active_model/validations'
require 'circuit/validators'

module Circuit
  module Storage
    module Sites
      module Model
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
