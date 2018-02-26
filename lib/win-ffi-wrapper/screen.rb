require 'win-ffi/core/struct/rect'

require 'win-ffi/gdi32/enum/device_context/device_context'
require 'win-ffi/gdi32/function/device_context'
require 'win-ffi/user32/enum/window/function/system_parameters_info_action'
require 'win-ffi/user32/function/window/configuration'
require 'win-ffi/user32/function/window/window'

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
        [width / 2, height / 2]
      end

      def work_area
        rect = RECT.new
        User32.SystemParametersInfo(User32::SPI_GETWORKAREA, 0, rect, 0)
        [rect[:right] - rect[:left], rect[:bottom] - rect[:top]]
      end

      def taskbar_height
        resolution[1] - work_area[1]
      end

      def width
        resolution[0]
      end

      def height
        resolution[1]
      end

      def dpi_x
        Gdi32.GetDeviceCaps(hdc, Gdi32::DeviceContext[:LOGPIXELSX])
      end

      def dpi_y
        Gdi32.GetDeviceCaps(hdc, Gdi32::DeviceContext[:LOGPIXELSY])
      end

      def dpi
        [dpi_x, dpi_y]
      end

      def get_system_metric(metric)
        User32.GetSystemMetrics(metric)
      end

      alias_method :desktop, :hwnd
    end
  end
end