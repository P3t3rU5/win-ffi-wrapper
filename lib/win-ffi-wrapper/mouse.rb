require 'win-ffi/user32/function/resource/cursor'

module WinFFIWrapper
  module Mouse
    include WinFFI

    def self.hide
      User32.ShowCursor(false)
    end

    def self.show
      User32.ShowCursor(true)
    end

    def self.position
      point = POINT.new
      User32.GetCursorPos(point)
      @x, @y = point.x, point.y
    end

    def self.set_position(x, y)
      User32.SetCursorPos(x, y)
    end

    def self.x
      position[0]
    end

    def self.y
      position[1]
    end
  end
end