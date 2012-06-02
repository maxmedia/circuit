require 'rack/request'

module Circuit
  module Rack
    autoload :Behavioral, 'circuit/rack/behavioral'
    autoload :MultiSite,  'circuit/rack/multi_site'

    require 'circuit/rack/request'
    ::Rack::Request.send(:include, Request)
  end
end
