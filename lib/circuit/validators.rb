require 'active_model/validator'

module Circuit
  module Validators
    DOMAIN_REGEXP = /\A(([a-z0-9]([a-z0-9\-]{0,61}[a-z0-9])?)\.)*([a-z]{2,}|([a-z0-9]([a-z0-9\-]{0,61}[a-z0-9])?))\Z/
    SLUG_REGEXP = /\A(?:[-_.!~*'()a-zA-Z\d:@&=+$,]|%[a-fA-F\d]{2})*(?:;(?:[-_.!~*'()a-zA-Z\d:@&=+$,]|%[a-fA-F\d]{2})*)*\Z/

    class DomainValidator < ActiveModel::EachValidator
      def initialize(options)
        options[:message] ||= "is not a valid domain."
        super(options)
      end

      def validate_each(record, attribute, value)
        record.errors.add attribute, options[:message] unless value =~ DOMAIN_REGEXP
      end
    end

    class DomainArrayValidator < ActiveModel::EachValidator
      def initialize(options)
        options[:message] ||= "has an invalid domain."
        super(options)
      end

      def validate_each(record, attribute, value)
        if Array.wrap(value).detect { |val| !(val =~ DOMAIN_REGEXP) }
          record.errors.add attribute, options[:message]
        end
      end
    end

    class SlugValidator < ActiveModel::EachValidator
      def initialize(options)
        options[:message] ||= "is not a valid path segment."
        super(options)
      end

      def validate_each(record, attribute, value)
        record.errors.add attribute, options[:message] unless value =~ SLUG_REGEXP
      end
    end
  end
end

DomainValidator = Circuit::Validators::DomainValidator
DomainArrayValidator = Circuit::Validators::DomainArrayValidator
SlugValidator = Circuit::Validators::SlugValidator
