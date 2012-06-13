module Circuit
  module Storage
    module Sites
      class MemoryStore < BaseStore
        def get(host)
          sites = Site.all.select {|s| s.host == host or s.aliases.include?(host)}
          if sites.length > 1
            raise MultipleFoundError, "Multiple sites found"
          end
          sites.first
        end

        class Site
          include Circuit::Storage::MemoryModel
          setup_attributes :host, :aliases, :route

          include Circuit::Storage::Sites::Model
          include Circuit::Storage::Sites::Model::Validations

          def initialize(opts={})
            memory_model_setup
            self.attributes = opts
            self.aliases ||= Array.new
          end

          def save
            return false if invalid?
            unless persisted?
              self.class.all << self
            end
            persisted!
          end
        end
      end
    end
  end
end
