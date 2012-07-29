module Circuit
  # Set of predefined middlewares to use with Circuit
  module Middleware
    autoload :Rewriter,     "circuit/middleware/rewriter"
    autoload :Fallthrough,  "circuit/middleware/fallthrough"
  end
end