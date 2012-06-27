require 'set'
require 'active_support/concern'
require 'active_support/configurable'
require 'active_support/callbacks'
require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/array/extract_options'

module Circuit
  private

  module ConfigurationCallbacks
    extend ActiveSupport::Concern

    included do
      # TODO validate self.config inherits from AS::Configurable::Configuration and is an anonymous class
      self.config.send(:include, Configuration)
    end

    private

    module Configuration
      extend ActiveSupport::Concern
      include ActiveSupport::Callbacks

      included do
        alias_method :_set, :[]= # preserve the original #[] method
        protected :_set # make it protected
        alias_method_chain :define_callbacks, :repeat_prevention
      end

      def before(get_set, key, *args, &block)
        name = _setup_for_callback(get_set, key)
        self.class.set_callback(name, :before, *args, &block)
      end

      def after(get_set, key, *args, &block)
        name = _setup_for_callback(get_set, key)
        self.class.set_callback(name, :after, *args, &block)
      end

      def around(get_set, key, *args, &block)
        name = _setup_for_callback(get_set, key)
        self.class.set_callback(name, :around, *args, &block)
      end

      private

      def _setup_for_callback(get_set, key)
        key = key.to_sym
        name = "#{get_set}_#{key}"

        case get_set.to_sym
        when :get
          if method_defined?(key)
            warn "Cannot setup callbacks for #{self}##{key}.  Method already defined."
          else
            class_eval <<-EOS, __FILE__, __LINE__ + 1
              def #{key}() run_callbacks(#{name.inspect}) { _get(#{key.inspect}) }; end
            EOS
          end
        when :set
          if method_defined?(:"#{key}=")
            warn "Cannot setup callbacks for #{self}##{key}.  Method already defined."
          else
            class_eval <<-EOS, __FILE__, __LINE__ + 1
              def #{key}=(val) run_callbacks(#{name.inspect}) { _set(#{key.inspect}, val) }; end
            EOS
          end
        else
          raise ArgumentError, "Invalid get_set parameter %p"%[get_set]
        end

        self.class.define_callbacks(name)
        return name
      end

      module ClassMethods
        private

        def define_callbacks_with_repeat_prevention(*args)
          options = args.extract_options!
          @@_callbacks_defined ||= Set.new

          args = args.collect do |name|
            name = name.to_sym
            if @@_callbacks_defined.include?(name)
              nil
            else
              @@_callbacks_defined << name
              name
            end
          end.tap(&:compact!)

          return if args.empty?

          args << options
          define_callbacks_without_repeat_prevention(*args)
        end
      end
    end
  end
end