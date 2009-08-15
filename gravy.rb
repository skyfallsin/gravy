module Gravy
  VERSION = 0.1
end

class Array
  def except(elem)
    self - [elem]
  end
end

require 'particle'
