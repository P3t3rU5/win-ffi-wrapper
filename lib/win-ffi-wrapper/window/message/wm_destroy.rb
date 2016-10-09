module WinFFIWrapper
  class Window
    private def wm_destroy(params)
      puts_msg :DESTROY, params.hwnd
      0
    end
    private :wm_destroy
  end
end