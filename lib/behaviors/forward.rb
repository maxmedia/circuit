module Behaviors
  class Forward
    include ::Circuit::Behavior

    def self.remap_by_segment
      true
    end
  end
end
