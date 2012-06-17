require 'rack/request'

module Circuit
  module Rack
    require 'circuit/rack/request'
    ::Rack::Request.send(:include, Request)

    require 'circuit/rack/builder'
    ::Rack::Builder.send(:include, BuilderExt)

    autoload :Behavioral, 'circuit/rack/behavioral'
    autoload :MultiSite,  'circuit/rack/multi_site'
  end
end
