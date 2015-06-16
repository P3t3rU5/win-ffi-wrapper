module WinFFIWrapper
  class Window
    # wParam - The identifier of the hot key that generated the message.
    def wm_hotkey(params)
      puts "hotkey #{params.wparam}"
      call_hooks(:on_hotkey, key: params.wparam)
      0
    end
    private :wm_hotkey
  end
end