using WinFFIWrapper::StringUtils

require 'win-ffi/user32/struct/window/create_struct'

module WinFFIWrapper
  class Window
    # lParam - A pointer to a CREATESTRUCT structure that contains information about the window being created.
    def wm_create(params)
      puts_msg :WM_CREATE, params.hwnd, nil, User32::CREATESTRUCT.new(FFI::Pointer.new(params.lparam))

      hinstance = DLL.module_handle
      # call_hooks :on_create
      0
    end
    private :wm_create
  end
end