using WinFFIWrapper::StringUtils

module WinFFIWrapper
  class Window
    # wParam - The virtual-key code of the nonsystem key.
    def wm_keyup(params)
      key = User32::VirtualKeyFlags[params.wparam]
      puts "keyup #{key}"

      call_hooks(:on_key_release, key: key)
      0
    end
    private :wm_keyup
  end
end