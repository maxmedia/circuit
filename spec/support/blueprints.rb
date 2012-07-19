require 'support/spec_helpers/simple_machinable'

module CircuitBlueprints
  def ensure_blueprints
    SimpleMachinable.ensure_machinable(::Site, ::RouteNode, Thing)
    SimpleMachinable.ensure_machinable(::MongoidSite, ::MongoidRouteNode) if $mongo_tests

    if ::Site.blueprint.nil?
      ::Site.blueprint do
        host      { 'example.org' }
        aliases   { %w[www.example.org subdomain.example.com] }
      end
    end

    if ::RouteNode.blueprint.nil?
      ::RouteNode.blueprint do
        slug            { Faker::Lorem.words(rand(3) + 2).join('-') }
        behavior_klass  { "RenderOk" }
      end
    end

    if $mongo_tests
      if ::MongoidSite.blueprint.nil?
        ::MongoidSite.blueprint do
          host      { 'example.org' }
          aliases   { %w[www.example.org subdomain.example.org] }
        end
      end

      if ::MongoidRouteNode.blueprint.nil?
        ::MongoidRouteNode.blueprint do
          slug            { Faker::Lorem.words(rand(3) + 2).join('-') }
          behavior_klass  { "RenderOk" }
        end
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
