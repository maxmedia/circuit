require 'rack/builder'

module Circuit
  module Rack
    module BuilderExt
      def app?
        !!@run
      end

      def initialize_copy(other)
        @use = other.instance_variable_get(:@use).dup
        unless other.instance_variable_get(:@map).nil?
          @map = other.instance_variable_get(:@map).dup
        end
      end
    end

    class Builder < ::Rack::Builder
      include BuilderExt

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
