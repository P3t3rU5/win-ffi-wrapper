module WinFFIWrapper
  class Window
    # wParam - The virtual-key code of the nonsystem key.
    def wm_keydown(params)
      key = User32::VirtualKeyFlags[params.wparam]
      puts "keydown #{key}"
      call_hooks(:on_key_press, key: key)
      0
    end
    private :wm_keydown
  end
end
