require 'win-ffi/user32/enum/interaction/keyboard/virtual_key_code'

module WinFFIWrapper
  class Window
    # wParam - The virtual-key code of the nonsystem key.
    private def wm_keydown(params)
      key = User32::VirtualKeyCode[params.wparam]
      call_hooks(:on_key_press, key: key)
      0
    end
  end
end
