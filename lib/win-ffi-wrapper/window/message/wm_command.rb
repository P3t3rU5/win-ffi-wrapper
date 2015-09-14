require 'win-ffi/enums/user32/window/notification/edit_notification'
require 'win-ffi/enums/user32/window/notification/button_notification'

require_relative '../../util'
module WinFFIWrapper
  class Window
    include Util

    def wm_command(params)

      id = loword(params.wparam)
      control = Control.get_control(id) if id > 0
      param = hiword(params.wparam)
      message = case param
                when 0
                  'menu'
                when 1
                  'accel'
                when User32::EditNotification[:SETFOCUS], User32::ButtonNotification[:SETFOCUS]
                  focused = focused_control
                  focused.send :killfocus if focused
                  set_value :focused_control, control
                  control.send(:setfocus) if control.respond_to? :setfocus, true
                  'SETFOCUS'
                when User32::EditNotification[:KILLFOCUS], User32::ButtonNotification[:KILLFOCUS]
                  control.send(:killfocus) if control.respond_to? :killfocus, true
                  'KILLFOCUS'
                when User32::EditNotification[:UPDATE]
                  control.send(:en_change) if control.respond_to? :en_update, true
                  'EN_UPDATE'
                when User32::EditNotification[:CHANGE]
                  control.send(:en_change) if control.respond_to? :en_change, true
                  'EN_CHANGE'
                when User32::EditNotification[:VSCROLL]
                  control.send(:en_vscroll) if control.respond_to? :en_vscroll, true
                  'EN_VSCROLL'
                when User32::EditNotification[:HSCROLL]
                  control.send(:en_hscroll) if control.respond_to? :en_hscroll, true
                  'EN_HSCROLL'
                else
                  "0x#{hiword(params.wparam).to_s(16)}"
                end
      puts_msg :WM_COMMAND, params.hwnd, [message, "id(#{id})"]
      puts "\t\t[#{'%#10s' % ('0x' + params.lparam.to_s(16))}] #{message.ljust(25)} id=#{id}]"
      # control.send(:call_hooks, :on_click)
      0
    end
  end
end