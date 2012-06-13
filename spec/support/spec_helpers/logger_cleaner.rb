require 'active_support/concern'

module SpecHelpers
  module LoggerCleaner
    extend ActiveSupport::Concern

    included do
      around :each do |example|
        orig_logger = Circuit.instance_variable_get(:@logger)
        Circuit.instance_variable_set(:@logger, nil) if orig_logger

        example.run

        Circuit.instance_variable_set(:@logger, orig_logger) if orig_logger
      end
    end
  end
end
