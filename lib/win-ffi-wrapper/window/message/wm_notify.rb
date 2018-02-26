# require 'win-ffi/user32/struct/window/control/notification_message_header'
#
# module WinFFIWrapper
#   class Window
#     private def wm_notify(params)
#       data = User32::NMHDR.new(FFI::Pointer.new(params.lparam))
#       info = [data.hwnd, data.idFrom, data.code]
#       # case data.code
#       #
#       # end
#       puts_msg :NOTIFY , params.hwnd, info
#       0
#     end
#   end
# end