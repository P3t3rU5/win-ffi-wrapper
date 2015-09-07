module WinFFIWrapper
  module Util
    def makeword(a, b)
      ((a & 0xff) | ((b & 0xff) << 8))
    end

    def makelong(a, b)
      ((a & 0xffff) | ((b & 0xffff) << 16))
    end

    def loword(l)
      l & 0xffff
    end

    def hiword(l)
      l >> 16
    end

    def lobyte(w)
      w & 0xff
    end

    def hibyte(w)
      w >> 8
    end
  end

  module StringUtils
    refine ::String do

      def to_utf8
        encode('utf-8')
      end

      def to_w
        encode('utf-16LE')
        # unless self.encoding.name == 'UTF-16LE'
      end
    end

    refine ::Object do
      def to_utf8
        to_s.to_utf8
      end

      def to_w
        to_s.to_w
      end
    end
  end
end

# class String
#   def to_utf8
#     encode('utf-8')
#   end
#
#   def to_w
#     encode('utf-16LE')
#   end
#
#   def to_utf8!
#     encode!('utf-8')
#   end
#
#   def to_w!
#     encode!('utf-16LE')
#   end
# end
#
# class Object
#   def to_utf8
#     to_s.to_utf8
#   end
#
#   def to_w
#     to_s.to_w
#   end
#
#   def to_utf8!
#     self.encode!('utf-8')
#   end
#
#   def to_w!
#     self.encode!('utf-16LE')
#   end
# end