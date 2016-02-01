using WinFFIWrapper::StringUtils

require 'win-ffi/user32/enum/interaction/keyboard/virtual_key_code'

module WinFFIWrapper
  class Window
    # wParam - The virtual-key code of the nonsystem key.
    def wm_keyup(params)
      key = User32::VirtualKeyCode[params.wparam]
      puts "keyup #{key}"

      call_hooks(:on_key_release, key: key)
      0
    end
    private :wm_keyup
  end
end