module WinFFIWrapper
  class Window
    # wParam - The identifier of the hot key that generated the message.
    private def wm_hotkey(params)
      modifiers = params.lparam
      call_hooks(:on_hotkey, key: params.wparam)
      0
    end
  end
end