use Circuit::Middleware::Rewriter do |*args|
      args
    end
run lambda { |env| [404, {"Content-Type" => "text/plain"}, ["Not Found"]] }
