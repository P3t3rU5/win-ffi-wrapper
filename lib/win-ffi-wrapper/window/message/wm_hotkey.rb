module WinFFIWrapper
  class Window
    # wParam - The identifier of the hot key that generated the message.
    private def wm_hotkey(params)
      modifiers = params.lparam

      LOGGER.debug "hotkey #{params.wparam}, #{modifiers}"
      call_hooks(:on_hotkey, key: params.wparam)
      0
    end
  end
end