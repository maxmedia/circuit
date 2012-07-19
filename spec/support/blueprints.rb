require 'support/spec_helpers/simple_machinable'

module CircuitBlueprints
  def ensure_blueprints
    SimpleMachinable.ensure_machinable(Circuit::Site, Circuit::Node, Thing)

    if Circuit::Site.blueprint.nil?
      Circuit::Site.blueprint do
        host      { 'example.org' }
        aliases   { %w[www.example.org subdomain.example.com] }
      end
    end

    if Circuit::Node.blueprint.nil?
      Circuit::Node.blueprint do
        slug            { Faker::Lorem.words(rand(3) + 2).join('-') }
        behavior_klass  { "RenderOk" }
      end
    end

    if Thing.blueprint.nil?
      Thing.blueprint do
        name { Faker::Lorem.words(rand(3) + 2).join(' ') }
      end
    end
  end
  module_function :ensure_blueprints
end

CircuitBlueprints.ensure_blueprints
