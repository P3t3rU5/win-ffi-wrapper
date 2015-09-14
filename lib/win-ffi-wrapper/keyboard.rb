require 'win-ffi/functions/user32/keyboard'
require 'win-ffi/enums/user32/virtual_key_flags'

module WinFFIWrapper
  module Keyboard
    def self.shift?
      (User32.GetKeyState(VirtualKeyFlags[:shift]) & 0x8000) != 0
    end

    def self.control?
      (User32.GetKeyState(VirtualKeyFlags[:ctrl]) & 0x8000) != 0
    end

    def self.alt?
      (User32.GetKeyState(VirtualKeyFlags[:alt]) & 0x8000) != 0
    end
  end
end