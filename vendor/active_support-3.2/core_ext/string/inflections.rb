## Copied from Rails 3.2.6 on 19 June 2012.
## see http://github.com/rails/rails/blob/v3.2.6/activesupport/lib/active_support/core_ext/string/inflections.rb

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

# String inflections define new methods on the String class to transform names for different purposes.
# For instance, you can figure out the name of a table from the name of a class.
#
#   "ScaleScore".tableize # => "scale_scores"
#
class String
  # Removes the module part from the constant expression in the string.
  #
  #   "ActiveRecord::CoreExtensions::String::Inflections".demodulize # => "Inflections"
  #   "Inflections".demodulize                                       # => "Inflections"
  #
  # See also +deconstantize+.
  def demodulize
    ActiveSupport::Inflector.demodulize(self)
  end

  # Removes the rightmost segment from the constant expression in the string.
  #
  #   "Net::HTTP".deconstantize   # => "Net"
  #   "::Net::HTTP".deconstantize # => "::Net"
  #   "String".deconstantize      # => ""
  #   "::String".deconstantize    # => ""
  #   "".deconstantize            # => ""
  #
  # See also +demodulize+.
  def deconstantize
    ActiveSupport::Inflector.deconstantize(self)
  end
end
