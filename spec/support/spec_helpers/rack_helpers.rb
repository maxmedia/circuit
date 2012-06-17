module SpecHelpers
  module RackHelpers
    def mock_request(env={})
      path = env.delete(:path) || "/foo/bar/baz"
      ::Rack::Request.new(Rack::MockRequest.env_for("http://www.example.com"+path, env))
    end
  end
end
