using WinFFIWrapper::StringUtils

require 'win-ffi/user32/function/window/dialog'
require 'win-ffi/user32/enum/window/flag/message_box_flags'

module WinFFIWrapper
  module Dialog
    include WinFFI

    class << self
      def message_box(text, *options, hwnd: nil, caption: nil)
        options = options.map { |o| o.is_a?(Symbol) ? User32::MessageBoxFlags[o] : o }.reduce(0, &:|)
        User32.MessageBox(hwnd, text.to_w, caption.to_w, options)
      end
    end
  end
end
