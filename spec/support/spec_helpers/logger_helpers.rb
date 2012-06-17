require 'active_support/concern'
require 'active_support/core_ext/module/delegation'

module SpecHelpers
  module LoggerHelpers
    extend ActiveSupport::Concern

    included do
      attr_reader :default_logger, :use_logger

      around :each do |example|
        @default_logger = Circuit.logger

        if clean_logger?
          Circuit.logger = nil
        elsif !default_logger?
          @logger_sio = StringIO.new
          Circuit.logger = Logger.new(@logger_sio)
        end

        example.run

        if clean_logger?
          clean_logger!(false)
        elsif !default_logger?
          @logger_sio.close
          @logger_sio = nil
        end

        Circuit.logger = @default_logger
      end
    end

    def use_logger!(key)
      @use_logger = (key ? key.to_sym : nil)
    end

    def use_logger?(key)
      @use_logger == key.to_sym
    end

    def clean_logger!(val=true)
      use_logger!(val ? :clean : false)
    end
    def clean_logger?() use_logger?(:clean); end

    def default_logger!(val=true)
      use_logger!(val ? :default : false)
    end
    def default_logger?() use_logger?(:default); end

    def logger_output
      raise "Clean logger used" if clean_logger?
      raise "Default logger used" if default_logger?
      @logger_sio.string
    end
  end
end
