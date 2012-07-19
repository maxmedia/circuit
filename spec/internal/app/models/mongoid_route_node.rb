if $mongo_tests
  class MongoidRouteNode
    include Circuit::Storage::Nodes::MongoidStore::Node

    belongs_to :site, :class_name => "MongoidSite", :inverse_of => :root
  end
end
