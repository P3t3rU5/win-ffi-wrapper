module WinFFIWrapper
  class Window
    # wParam - Indicates whether various virtual keys are down.
    private def wm_mousewheel(params)
      rotation = params.wparam >> 16
      rotation = rotation - 65536 if ((rotation >> 15) & 1) == 1
      keymode = params.wparam & 0xFFFF
      puts_msg :MOUSEWHEEL, params.hwnd, [rotation, keymode]
      LOGGER.debug "rotation = #{rotation} ; keymode = #{keymode}"
      call_hooks(:on_mousewheel, rotation: rotation, keymode: keymode)
      0
    end
  end
end