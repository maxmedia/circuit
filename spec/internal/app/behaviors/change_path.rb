module ChangePath
  include Circuit::Behavior

  use Circuit::Middleware::Rewriter do |script_name, path_info|
        ["/site/5#{script_name}", path_info]
      end
end
