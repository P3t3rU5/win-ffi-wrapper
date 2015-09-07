module WinFFIWrapper
  class Window
    def wm_killfocus(params)
      puts_msg :WM_KILLFOCUS, params.hwnd
      0
    end
  end
end