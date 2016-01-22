require 'win-ffi/user32/struct/nmhdr'

module WinFFIWrapper
  class Window
    def wm_notify(params)
      data = User32::NMHDR.new(FFI::Pointer.new(params.lparam))
      info = [data.hwnd, data.idFrom, data.code]
      # case data.code
      #
      # end
      puts_msg :WM_NOTIFY , params.hwnd, info
      0
    end
    private :wm_notify
  end
end