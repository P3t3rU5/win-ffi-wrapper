require 'win-ffi/core/macro/util'

module WinFFIWrapper
  class Window
    private def wm_contexmenu(params)

      # id = loword(params.wparam)
      # control = Control.get_control(id) if id > 0
      # param = hiword(params.wparam)
      # message = control.command(param) || "0x#{hiword(params.wparam).to_s(16)}"

      handle = wparam
      x = loword(params.lparam)
      y = hiword(params.lparam)


      puts_msg :CONTEXMENU, params.hwnd, [handle, "(#{x},#{y})"]
      LOGGER.debug "\t\t[#{'%#10s' % ('0x' + params.lparam.to_s(16))}] #{message.ljust(25)} id=#{id}]"
      0
    end
  end
end