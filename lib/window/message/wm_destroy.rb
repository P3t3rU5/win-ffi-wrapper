module WinFFIWrapper
  class Window
    def wm_destroy(params)
      puts_msg :WM_DESTROY, params.hwnd
      0
    end
    private :wm_destroy
  end
end