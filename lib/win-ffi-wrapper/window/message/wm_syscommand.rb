require 'win-ffi/user32/enum/window/system_menu_command'

module WinFFIWrapper
  class Window
    def wm_syscommand(params)

      command = User32::SystemMenuComand[params.wparam & 0xFFF0]

      puts_msg :WM_SYSCOMMAND, params.hwnd, [command, params.lparam]

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
      else
        nil
      end
    end
  end
end