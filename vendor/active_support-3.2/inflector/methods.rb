## Copied from Rails 3.2.6 on 19 June 2012.
## see http://github.com/rails/rails/blob/v3.2.6/activesupport/lib/active_support/inflector/methods.rb

# Copyright (c) 2005-2011 David Heinemeier Hansson
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module ActiveSupport
  # The Inflector transforms words from singular to plural, class names to table names, modularized class names to ones without,
  # and class names to foreign keys. The default inflections for pluralization, singularization, and uncountable words are kept
  # in inflections.rb.
  #
  # The Rails core team has stated patches for the inflections library will not be accepted
  # in order to avoid breaking legacy applications which may be relying on errant inflections.
  # If you discover an incorrect inflection and require it for your application, you'll need
  # to correct it yourself (explained below).
  module Inflector
    extend self

    # Removes the module part from the expression in the string:
    #
    #   "ActiveRecord::CoreExtensions::String::Inflections".demodulize # => "Inflections"
    #   "Inflections".demodulize                                       # => "Inflections"
    #
    # See also +deconstantize+.
    def demodulize(path)
      path = path.to_s
      if i = path.rindex('::')
        path[(i+2)..-1]
      else
        path
      end
    end

    # Removes the rightmost segment from the constant expression in the string:
    #
    #   "Net::HTTP".deconstantize   # => "Net"
    #   "::Net::HTTP".deconstantize # => "::Net"
    #   "String".deconstantize      # => ""
    #   "::String".deconstantize    # => ""
    #   "".deconstantize            # => ""
    #
    # See also +demodulize+.
    def deconstantize(path)
      path.to_s[0...(path.rindex('::') || 0)] # implementation based on the one in facets' Module#spacename
    end
  end
end
