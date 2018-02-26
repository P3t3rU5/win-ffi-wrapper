require 'win-ffi/user32/enum/interaction/mouse/mouse_keys_state'

module WinFFIWrapper
  class Window
    # wParam - Indicates whether various virtual keys are down.
    # lParam The low-order word specifies the x-coordinate of the cursor.
    #        The high-order word specifies the y-coordinate of the cursor.
    private def wm_mousemove(params)
      wparam, lparam = params.wparam, params.lparam

      omx, omy = mousex, mousey

      set_value :mousex, lparam & 0xFFFF
      set_value :mousey, lparam >> 16

      flags = User32::MouseKeysState.symbols.map { |f| [f, (wparam & User32::MouseKeysState[f]) != 0] }
      flags = Hash[flags]

      call_hooks(:on_mousemove, flags)
      0
    end
  end
end