require 'win-ffi'

module WinFFIWrapper
  module Mouse

    # def self.hide
    #   puts 'hiding'
    #   sc = User32.ShowCursor(false)
    #   puts sc
    #   while sc >=0
    #
    #     sc = User32.ShowCursor(false)
    #   end
    # end
    #
    # def self.show
    #   User32.ShowCursor(true)
    # end

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