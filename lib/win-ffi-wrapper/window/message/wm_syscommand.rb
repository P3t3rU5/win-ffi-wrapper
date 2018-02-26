require 'win-ffi/user32/enum/window/message/system_menu_command'

module WinFFIWrapper
  class Window
    private def wm_syscommand(params)

      command = User32::SystemMenuComand[params.wparam & 0xFFF0]

      puts_msg :SYSCOMMAND, params.hwnd, [command, params.lparam]

      case command
        when :RESTORE
          self.state = :restored
        when :MAXIMIZE
          self.state = :maximized
        when :MINIMIZE
          self.state = :minimized
        when :CLOSE
          return nil unless call_handlers :on_before_close
        else
          return nil
      end
      0
    end
  end
end