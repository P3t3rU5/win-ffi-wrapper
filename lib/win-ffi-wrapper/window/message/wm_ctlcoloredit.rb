module WinFFIWrapper
  class Window
    private def wm_ctlcoloredit(params)
      User32.InvalidateRect(@hwnd, nil, false)
      0
    end
  end
end