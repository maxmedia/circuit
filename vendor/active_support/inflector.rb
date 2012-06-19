require 'active_support/inflector'

## Copied from ActiveSupport 3.2.6 to add to 3.1.x

module ActiveSupport
  module InflectorExt
    def demodulize(path)
      path = path.to_s
      if i = path.rindex('::')
        path[(i+2)..-1]
      else
        path
      end
    end

    def deconstantize(path)
      path.to_s[0...(path.rindex('::') || 0)] # implementation based on the one in facets' Module#spacename
    end
  end
  ActiveSupport::Inflector.send(:extend, InflectorExt)
end

class String
  def demodulize
    ActiveSupport::Inflector.demodulize(self)
  end

  def deconstantize
    ActiveSupport::Inflector.deconstantize(self)
  end
end
