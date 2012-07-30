require 'active_support/concern'

module SpecHelpers
  module IntegrationTestHelper
    extend ActiveSupport::Concern

    include BaseModels
    include Rack::Test::Methods

    included do
      let(:thing)   { Thing.make! }
      let(:thing_1) { Thing.make! }
      let(:thing_2) { Thing.make! }

      before do
        child.slug = "things"
        child.behavior = Circuit::Behavior.get("Things")
        child.infinite = true
        child.save!
        thing; thing_1; thing_2
      end
    end

    def app
      Combustion::Application
    end
  end
end
