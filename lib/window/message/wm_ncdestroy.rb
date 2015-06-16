module WinFFIWrapper
  class Window
    def wm_ncdestroy(params)
      puts_msg :WM_NCDESTROY, params.hwnd

      #@context.unbind
      #num_win = self.class.instance_eval{ @windows -= 1 }
      #
      #User32.UnregisterClass(FFI::Pointer.new(@wc.atom), @hinstance)
      #User32.PostQuitMessage(0) if num_win == 0

      #This message should return nil for the system to free handle by calling the default
      nil
    end
    private :wm_ncdestroy
  end
end