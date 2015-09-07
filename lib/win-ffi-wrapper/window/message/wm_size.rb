module WinFFIWrapper
  class Window
    SIZE = {
        0 => :RESTORED,
        1 => :MINIMIZED,
        2 => :MAXIMIZED,
        3 => :MAXSHOW,
        4 => :MAXHIDE
    }

    # wParam - The type of resizing requested.
    # lParam - The low-order word of lParam specifies the new width of the client area.
    #          The high-order word of lParam specifies the new height of the client area.
    def wm_size(params)
      wparam, lparam = params.wparam, params.lparam
      w, h = lparam & 0xffff, lparam >> 16
      puts_msg :WM_SIZE, params.hwnd, "resizeType = #{SIZE[wparam].inspect}, width = #{w}, height = #{h}"
      User32.InvalidateRect(@hwnd, nil, true)
      return 0 if wparam == 1 #SIZE[wparam] == :MINIMIZED
      resize
      1
    end
    private :wm_size
  end
end