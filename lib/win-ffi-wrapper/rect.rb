require 'facets/kernel/ergo'

module WinFFIWrapper
  class Rect
    attr_accessor :x, :y, :width, :height

    def initialize(x = 0, y = 0, width = 0, height = 0, &block)
      self.x, self.y, self.width , self.height = x, y, width, height
      ergo &block
    end

    def [](v)
      send v
    end

    def []=(k, v)
      send("#{k}=", v)
    end

    def ==(r)
      return false unless r.is_a? Rect
      %w(x y width height).map{ |v| self[v] == r[v] }.all?{ |v| v }
    end

    def add(x, y)
      self.left   = x if x < left
      self.right  = x if x > right
      self.top    = y if y < top
      self.bottom = y if y > bottom
      nil
    end

    def area
      width * height
    end

    def perimeter
      2 * width + 2 * height
    end

    def bottom
      y + height
    end

    def bottom=(v)
      raise ArgumentError, "can't set a bottom lower than the top" if v <= y
      self.height = v - y
    end

    def center
      [center_x, center_y]
    end

    def center_x
      x + width/2
    end

    def center_y
      y + height/2
    end

    def center=(c)
      cx, cy = c
      self.x, self.y = cx - width/2, cy - height/2
    end

    def include?(x, y)
      (left..right).include?(x) && (top..bottom).include?(y)
    end

    def outside?(x, y)
      !include?(x, y)
    end

    def right
      x + width
    end

    def right=(v)
      self.width = v - x
    end

    def size
      Size.new(width, height)
    end

    def to_a
      [left, top, width, height]
    end

    def to_s
      "<Rect #{%w'left top width height'.map { |name| "#{name} = #{send(name)}" }.join(', ')}>"
    end

    def to_native
      r = RECT.new
      r.left, r.top, r.right, r.bottom = x, y, width, height
      r
    end

    def vertices(format = :strip)
      case format
        when :strip then [[left, top], [right, top], [left, bottom], [right, bottom]]
        when :cycle then [[left, top], [right, top], [right, bottom], [left, bottom]]
        else nil
      end
    end

    def self.from_center(cx, cy, width, height)
      new do
        self.x, self.y, self.width, self.height = cx - width/2, cy - height/2, width, height
      end
    end

    alias_method :to_ary,  :to_a
    alias_method :inside?, :include?
    alias_method :left,    :x
    alias_method :left=,   :x=
    alias_method :top,     :y
    alias_method :top=,    :y=

  end
end
