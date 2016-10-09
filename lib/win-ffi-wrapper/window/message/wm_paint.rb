module WinFFIWrapper
  class Window
    private def wm_paint(params)
      puts_msg :PAINT, params.hwnd
      # User32.InvalidateRect(@hwnd, nil, false)
      # User32.ValidateRect(@hwnd, nil)
      ps = WinFFI::PAINTSTRUCT.new
      User32.InvalidateRect(@hwnd, nil, true)
      User32.BeginPaint(@hwnd, ps)
      User32.EndPaint(@hwnd, ps)
      0
    end
  end
end