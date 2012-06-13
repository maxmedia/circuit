require_relative 'spec_helpers/simple_machinable'

module CircuitBlueprints
  def ensure_blueprints
    SimpleMachinable.ensure_machinable(Circuit::Site, Circuit::Tree)

    if Circuit::Site.blueprint.nil?
      Circuit::Site.blueprint do
        host      { 'example.org' }
        aliases   { %w[www.example.org subdomain.example.com] }
      end
    end

    if Circuit::Tree.blueprint.nil?
      Circuit::Tree.blueprint do
        slug      { Faker::Lorem.words(rand(3) + 2).join('-') }
        behavior  { Behaviors::MountByFragmentOrRemap }
      end
    end
  end
  module_function :ensure_blueprints
end

CircuitBlueprints.ensure_blueprints
