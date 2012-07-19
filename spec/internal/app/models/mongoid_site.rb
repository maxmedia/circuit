if $mongo_tests
  class MongoidSite
    include Circuit::Storage::Sites::MongoidStore::Site

    has_one :root, :class_name => "MongoidRouteNode", :inverse_of => :site
  end
end
