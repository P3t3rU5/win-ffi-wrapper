module WinFFIWrapper
  class Window
    include WinFFI
    private def wm_command(params)
      command = WinFFI.HIWORD(params.wparam)
      id = WinFFI.LOWORD(params.wparam)
      control = Control.get_control(id) if id > 0
      message = "#{control.class.to_s.split('::')[-1]} id=#{id} #{control&.command(command)}"
      puts_msg :COMMAND, params.hwnd, [message, "id(#{id})"]
      LOGGER.info "\t\t[#{'%#10s' % ('0x' + params.lparam.to_s(16))}] #{message.ljust(25)} id=#{id}]"
      0
    end
  end
end