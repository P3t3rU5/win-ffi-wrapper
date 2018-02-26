require 'win-ffi/core/macro/util'
require 'win-ffi/user32/enum/window/control/scrollbar/scrollbar_horizontal'

module WinFFIWrapper
  class Window
    private def wm_vscroll(params)
      control_handle = params.lparam
      request = User32::ScrollbarHorizontal[WinFFI::LOWORD(params.wparam)]

      si = SCROLLINFO.new
      si.fMask = :ALL
      User32.GetScrollInfo(@hwnd, :HORZ, si)

      call_hooks(:on_horizontal_scroll, request: request, si: si) || 1
    end
  end
end