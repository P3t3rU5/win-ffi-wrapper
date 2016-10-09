require 'win-ffi/user32/function/interaction/keyboard'

module WinFFIWrapper
  module Input
    class << self
      def block_input
        User32.BlockInput(true)
      end

      def unblock_input
        User32.BlockInput(true)
      end


    end
  end
end