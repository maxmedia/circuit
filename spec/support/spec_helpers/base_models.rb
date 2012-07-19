# constructs 2 different trees of routing for our examples purposes.
#
#     + root
#       + child
#         + grandchild
#           + great_grandchild
#
# And a more complex version:
#
#     + root_1
#       + child_1
#         + grandchild_1
#         + grandchild_2
#           + great_grandchild_1
#           + great_grandchild_2
#       + child_2
#         + grandchild_3
#           + great_grandchild_3
#     + root_2
#
# This include doesn't take into account any slug information(as they are generated
# by the Circuit::Node blueprint already).  Also, each of these is persisted, so if you want
# something faster or don't require routing tree, you should consider using a stub or
# `node_class.make` to generate a non-persisted record.
#
require 'active_support/concern'

module SpecHelpers
  module BaseModels
    extend ActiveSupport::Concern

    included do
      let(:node_class) { ($mongo_tests? ::MongoidRouteNode : ::RouteNode) }
      let(:site_class) { ($mongo_tests? ::MongoidSite : ::Site) }

      let(:site_1)                    { site_class.make! :host => "www.foo.com", :aliases => [] }
      let(:root_1)                    { node_class.make! :slug => nil, :site => site_1 }
        let(:child_1)                 { node_class.make! :parent => root_1       }
          let(:grandchild_1)          { node_class.make! :parent => child_1      }
          let(:grandchild_2)          { node_class.make! :parent => child_1      }
            let(:great_grandchild_1)  { node_class.make! :parent => grandchild_2 }
            let(:great_grandchild_2)  { node_class.make! :parent => grandchild_2 }
        let(:child_2)                 { node_class.make! :parent => root_1       }
          let(:grandchild_3)          { node_class.make! :parent => child_2      }
            let(:great_grandchild_3)  { node_class.make! :parent => grandchild_3 }

      let(:site_2)                    { site_class.make! :host => "www.bar.com", :aliases => [] }
      let(:root_2)                    { node_class.make! :slug => nil, :site => site_2 }

      let(:site)                      { site_class.make! :host => "example.org", :aliases => ["www.example.org"] }
      let(:root)                      { node_class.make! :slug => nil, :site => site }
      let(:child)                     { node_class.make! :parent => root         }
      let(:grandchild)                { node_class.make! :parent => child        }
      let(:great_grandchild)          { node_class.make! :parent => grandchild   }

      let(:dup_site_1)         { site_class.make! :host => "dup1.com", :aliases => [] }
      let(:dup_site_1_dup)     { site_class.make! :host => "dup1.com", :aliases => %w[foo.com] }
      let(:dup_site_2)         { site_class.make! :host => "dup2.com", :aliases => [] }
      let(:dup_site_2_dup)     { site_class.make! :host => "bar.com", :aliases => %w[dup2.com] }
      let(:dup_site_3)         { site_class.make! :host => "wow1.com", :aliases => %w[dup3.com] }
      let(:dup_site_3_dup)     { site_class.make! :host => "wow2.com", :aliases => %w[dup3.com] }
    end
  end
end
