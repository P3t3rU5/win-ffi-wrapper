module WinFFIWrapper
  class Window
    # lParam - A pointer to a WINDOWPOS structure that contains information about the window's new size and position.
    private def wm_windowposchanged(params)
      pos = User32::WINDOWPOS.new(FFI::Pointer.new(params.lparam))

      puts_msg :WINDOWPOSCHANGED, params.hwnd, nil, pos

      placement = User32::WINDOWPLACEMENT.new
      User32.GetWindowPlacement(@hwnd, placement)
      #LOGGER.debug "\t\tWindowPlacement -> #{placement}"

      %i'left top width height'.each { |n| set_value n, pos[n] }

      resize unless pos.flags.member?(:NOSIZE)

      0
    end
  end
end