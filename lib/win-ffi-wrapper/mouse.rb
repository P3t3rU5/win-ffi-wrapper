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
      @position = POINT.new
      User32.GetCursorPos(@position)
      @position
    end

    def self.set_position(x, y)
      User32.SetCursorPos(x, y)
    end

    def self.x
      position.x
    end

    def self.y
      position.y
    end
  end
end