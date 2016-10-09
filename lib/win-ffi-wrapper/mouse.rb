require 'win-ffi/user32/function/resource/cursor'
require 'win-ffi/user32/struct/resource/cursor/cursor_info'

module WinFFIWrapper
  module Mouse
    class << self
      include WinFFI
      def hide
        User32.ShowCursor(false)
      end

      def hidden?
        cursor_info = User32::CURSORINFO.new
        User32.GetCursorInfo(cursor_info)
        User32::CursorInfoFlag[cursor_info.flags] == :HIDDEN
      end

      def show
        User32.ShowCursor(true)
      end

      def visible?
        cursor_info = User32::CURSORINFO.new
        User32.GetCursorInfo(cursor_info)
        cursor_info.flags == :SHOWING
      end

      def get_position
        point = POINT.new
        User32.GetCursorPos(point)
        @x, @y = point.x, point.y
      end

      def set_position(x, y)
        WinFFI::User32.SetCursorPos(x, y)
      end

      def x
        get_position[0]
      end

      def y
        get_position[1]
      end

      alias_method :position,  :get_position
      alias_method :position=, :set_position
    end
  end
end