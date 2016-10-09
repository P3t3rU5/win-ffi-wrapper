require 'win-ffi/user32/function/interaction/keyboard'
require 'win-ffi/user32/enum/interaction/keyboard/virtual_key_code'

module WinFFIWrapper
  module Keyboard
    class << self
      include WinFFI

      def shift?
        (User32.GetKeyState(User32::VirtualKeyCode[:SHIFT]) & 0x8000) != 0
      end

      def control?
        (User32.GetKeyState(User32::VirtualKeyCode[:CONTROL]) & 0x8000) != 0
      end

      def alt?
        (User32.GetKeyState(User32::VirtualKeyCode[:MENU]) & 0x8000) != 0
      end

      def get_key_name(key)
        name = nil
        key = key.upcase
        return unless Userr32::VirtualKeyCode.symbols.includes? key
        FFI::MemoryPointer.new(:char, 255) do |name|
          key = User32.MapVirtualKey(key, :VK_TO_VSC)
          length = User32.GetKeyNameText((key << 16), name, 255)
          name = name.read_array_of_uchar(length * 2).pack('U*')
        end
        name
      end

      def send_input(key:, position:, time: 0)
        keyboard = INPUT.new
        keyboard.type = InputType[:KEYBOARD]
        keyboard.u.ki = KEYBDINPUT.new
        keyboard.u.ki.wVk = VirtualKeyCode[key]
        keyboard.u.ki.dwFlags = KeyboardEventFlag[position]
        keyboard.u.ki.time = time
        FFI::MemoryPointer.new(:pointer) do |input|
          input.write_array_of_pointer([keyboard])
          User32.SendInput(1, input, keyboard.size) == 1
        end
      end
    end
  end
end