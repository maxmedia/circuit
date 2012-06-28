require 'rack'
require 'active_support'
require 'active_support/concern'
require 'active_support/core_ext/kernel/reporting'
require 'dionysus/string/version_match'

module Circuit
  # Compatibility extensions for Rack 1.3 and Rails 3.1
  module Compatibility
    # Make Rack 1.3 and ActiveSupport 3.1 compatible with circuit.
    # * Overrides Rack::Builder and Rack::URLMap with the classes from Rack 1.4
    # * Adds #demodulize and #deconstantize inflections to ActiveSupport
    def self.make_compatible
      rack13 if ::Rack.release.version_match?("~> 1.3.0")
      active_support31 if ActiveSupport::VERSION::STRING.version_match?("~> 3.1.0")
    end

    # Include in a model to modify it for compatibility.
    module ActiveModel31
      extend ActiveSupport::Concern

      # @!method define_attribute_methods(*args)
      #   Modified to call `attribute_method_suffix ''` first to create the 
      #   accessors.
      #   @see http://rubydoc.info/gems/activemodel/ActiveModel/AttributeMethods/ClassMethods#define_attribute_methods-instance_method
      #   @see http://rubydoc.info/gems/activemodel/ActiveModel/AttributeMethods/ClassMethods#attribute_method_suffix-instance_method

      included do
        if ActiveModel::VERSION::STRING.version_match?("~> 3.1.0")
          if has_active_model_module?("AttributeMethods")
            class << self
              alias_method_chain :define_attribute_methods, :default_accessor
            end
          end
        end
      end

      private

      module ClassMethods
        def has_active_model_module?(mod_name)
          included_modules.detect {|mod| mod.to_s == "ActiveModel::#{mod_name.to_s.camelize}"}
        end

        def define_attribute_methods_with_default_accessor(*args)
          attribute_method_suffix ''
          define_attribute_methods_without_default_accessor(*args)
        end
      end
    end

    private

    def self.vendor_path
      Circuit.vendor_path
    end

    def self.rack13
      require "rack/urlmap"
      require "rack/builder"

      require vendor_path.join("rack-1.4", "builder").to_s
      silence_warnings { require vendor_path.join("rack-1.4", "urlmap").to_s }
    end

    def self.active_support31
      require "active_support/inflector"

      require vendor_path.join("active_support-3.2", "inflector", "methods").to_s
      require vendor_path.join("active_support-3.2", "core_ext", "string", "inflections").to_s
    end
  end
end
