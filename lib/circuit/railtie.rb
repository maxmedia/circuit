module Circuit
  # Initializer `circuit_railtie.configure_rails_initialization`
  # ------------------------------------------------------------
  # * adds Rack::MultiSite and Rack::Behavioral to the Rails middleware stack
  # * Sets the Circuit logger to the Rails logger
  class Railtie < Rails::Railtie
    initializer "circuit_railtie.configure_rails_initialization" do |app|
      app.middleware.use Rack::MultiSite
      app.middleware.use Rack::Behavioral
      Circuit.logger = app.config.logger
    end
  end
end
