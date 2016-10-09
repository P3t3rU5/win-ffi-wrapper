module WinFFIWrapper
  class Window
    private def wm_killfocus(params)
      puts_msg :KILLFOCUS, params.hwnd
      0
    end
  end
end