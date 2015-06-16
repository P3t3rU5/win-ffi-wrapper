require 'win-ffi/enums/user32/window/system_menu_command'

require_relative '../lib/window'
require_relative '../lib/window/style'

include WinFFIWrapper
include WinFFI::User32

w = Window.new(title: '1º',
               taskbar_icon: Icon.new("C:\\Users\\Pedro\\Theme\\IST_Logo.ico"),
               style: style)
hsys = GetSystemMenu(w.hwnd, false)
InsertMenu(hsys, User32::SystemMenuComand[:CLOSE], :STRING, 0, "Item&1\tAlt+S".to_w)
InsertMenu(hsys, SUser32::SystemMenuComand[:CLOSE], :SEPARATOR, 0, nil)
w.show