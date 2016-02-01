require 'win-ffi/general/struct/rect'

require 'win-ffi/gdi32/function/device_context'

module WinFFIWrapper
  module Screen
    class << self
      include WinFFI
      def hwnd
        User32.GetDesktopWindow
      end

      def hdc
        User32.GetDC(nil)
      end

      def resolution
        rect = RECT.new
        User32.GetWindowRect(hwnd, rect)
        [rect[:right] - rect[:left], rect[:bottom] - rect[:top]]
      end

      def center
        width, height = resolution
        [width/2, height/2]
      end

      def width
        resolution[0]
      end

      def height
        resolution[1]
      end

      def dpi_x
        Gdi32.GetDeviceCaps(hdc, Gdi32::LOGPIXELSX)
      end

      def dpi_y
        Gdi32.GetDeviceCaps(hdc, Gdi32::LOGPIXELSY)
      end

      def dpi
        dc = hdc
        [Gdi32.GetDeviceCaps(dc, Gdi32::LOGPIXELSX), Gdi32.GetDeviceCaps(dc, Gdi32::LOGPIXELSY)]
      end
    end
  end
end