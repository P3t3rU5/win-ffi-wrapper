module WinFFIWrapper
  class Window

    def wm_command(params)

      id = loword(params.wparam)
      control = Control.get_control(id) if id > 0
      param = hiword(params.wparam)
      message = control.command(param) || "0x#{hiword(params.wparam).to_s(16)}"

      puts_msg :WM_COMMAND, params.hwnd, [message, "id(#{id})"]
      puts "\t\t[#{'%#10s' % ('0x' + params.lparam.to_s(16))}] #{message.ljust(25)} id=#{id}]"

      0
    end
  end
end