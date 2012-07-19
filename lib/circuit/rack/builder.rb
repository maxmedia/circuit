require 'rack/server'
require 'rack/builder'

module Circuit
  module Rack
    # Extensions to Rack::Builder
    module BuilderExt
      # @return [Boolean] true if a default app is set
      def app?
        !!@run
      end

      # Duplicates the `@use` Array and `@map` Hash instance variables
      def initialize_copy(other)
        @use = other.instance_variable_get(:@use).dup
        unless other.instance_variable_get(:@map).nil?
          @map = other.instance_variable_get(:@map).dup
        end
      end
    end

    # A Rack::Builder variation that does not require a fully-compliant rackup
    # file; specifically that a default app (`run` directive) is not required.
    class Builder < ::Rack::Builder
      include BuilderExt

      # Parses the rackup (or circuit-rackup .cru) file.
      # @return [Circuit::Rack::Builder, options] the builder and any parsed options
      def self.parse_file(config, opts = ::Rack::Server::Options.new)
        # allow for objects that are String-like but don't respond to =~ 
        # (e.g. Pathname)
        config = config.to_s

        if config.to_s =~ /\.cru$/
          options = {}
          cfgfile = ::File.read(config)
          cfgfile.sub!(/^__END__\n.*\Z/m, '')
          builder = eval "%s.new {\n%s\n}"%[self, cfgfile], TOPLEVEL_BINDING, config
          return builder, options
        else
          # this should be a fully-compliant rackup file (or a constant name),
          # so use the real Rack::Builder, but return a Builder object instead 
          # of the app
          app, options = ::Rack::Builder.parse_file(config, opts)
          return self.new(app), options
        end
      end
    end
  end
end
