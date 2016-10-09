require 'win-ffi/user32/enum/window/message/system_menu_command'

module WinFFIWrapper
  class Window
    private def wm_syscommand(params)

      command = User32::SystemMenuComand[params.wparam & 0xFFF0]

      puts_msg :SYSCOMMAND, params.hwnd, [command, params.lparam]

      case command
        when :RESTORE
          self.state = :restored
          0
        when :MAXIMIZE
          self.state = :maximized
          0
        when :MINIMIZE
          self.state = :minimized
          0
        when :CLOSE
          call_hooks :on_before_close
          0
        else
          nil
      end
    end
  end
end