module Circuit
  class Railtie < Rails::Railtie
    initializer "circuit_railtie.configure_rails_initialization" do |app|
      app.middleware.use Rack::MultiSite
      app.middleware.use Rack::Behavioral
      Circuit.logger = app.config.logger
    end
  end
end
