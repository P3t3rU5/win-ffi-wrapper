module WinFFIWrapper
  class Window
    # wParam - A handle to the device context.
    def wm_erasebkgnd(params)
      puts_msg :WM_ERASEBKGND, params.hwnd, params.wparam
      User32.InvalidateRect(@hwnd, nil, true)
      1
    end
    private :wm_erasebkgnd
  end
end