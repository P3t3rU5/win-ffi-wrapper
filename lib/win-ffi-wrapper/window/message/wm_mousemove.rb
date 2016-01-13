require 'win-ffi/user32/enum/mouse_keys_flags'

module WinFFIWrapper
  class Window
    # wParam - Indicates whether various virtual keys are down.
    # lParam The low-order word specifies the x-coordinate of the cursor.
    #        The high-order word specifies the y-coordinate of the cursor.
    def wm_mousemove(params)
      wparam, lparam = params.wparam, params.lparam

      omx, omy = mousex, mousey

      set_value :mousex, lparam & 0xFFFF
      set_value :mousey, lparam >> 16

      # self.title = "#{mousex}:#{mousey}"

      flags = User32::MouseKeysFlags.symbols.map { |f| [f, (wparam & User32::MouseKeysFlags[f]) != 0] }
      flags = Hash[flags]

      call_hooks(:on_mousemove, flags)
      0
    end
    private :wm_mousemove
  end
end