module WinFFIWrapper
  class Window
    # wParam - character
    # lParam - The repeat count (0-15), scan code (16-23), extended-key flag (24), context code (29),
    #          previous key-state flag (30), and transition-state flag (31).
    private def wm_char(params)
      puts_msg :CHAR, params.hwnd, [params.wparam].pack('U')

      call_hooks :on_char, params.dup

      0
    end
  end
end