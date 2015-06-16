module WinFFIWrapper
  class Window
    # private def wm_nccreate(params)
    #   User32.SetWindowLongW(params.hwnd, User32::GetWindowLongFlags[:USERDATA], User32::CREATESTRUCT.new(FFI::Pointer.new(params.lparam))[:lpCreateParams].to_i)
    #   1
    # end
  end
end