module Circuit
  # Initializer `circuit_railtie.configure_rails_initialization`
  # ------------------------------------------------------------
  # * adds Rack::MultiSite and Rack::Behavioral to the Rails middleware stack
  # * Sets the Circuit logger to the Rails logger
  class Railtie < Rails::Railtie
    initializer "circuit_railtie.configure_rails_initialization" do |app|
      app.middleware.insert 0, Rack::MultiSite
      app.middleware.insert 1, Rack::Behavioral

      unless Circuit.cru_path
        Circuit.cru_path = app.root.join("app", "behaviors")
      end

      root = app.root.expand_path.to_s
      rel = Circuit.cru_path.expand_path.to_s.gsub(/^#{Regexp.escape(root)}\//, "")
      app.config.paths.add rel, :eager_load => true, :glob => "**/*.rb"

      app.config.after_initialize do
        Circuit.logger = Rails.logger
      end
    end
  end
end
