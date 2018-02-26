require 'win-ffi/core/macro/util'
require 'win-ffi/user32/enum/window/control/scrollbar/scrollbar_vertical'

module WinFFIWrapper
  class Window
    private def wm_vscroll(params)
      control_handle = params.lparam
      request = User32::ScrollbarVertical[WinFFI::LOWORD(params.wparam)]

      si = SCROLLINFO.new
      si.fMask = :ALL
      User32.GetScrollInfo(@hwnd, :VERT, si)

      call_hooks(:on_vertical_scroll, request: request, si: si) || 1
    end
  end
end