using WinFFIWrapper::StringUtils

require 'win-ffi/user32/function/window/dialog'
require 'win-ffi/user32/enum/window/message_box_flag'
require 'win-ffi/user32/enum/window/control/dialog/dialog_box_command_id'

module WinFFIWrapper
  module Dialog
    class << self
      include WinFFI
      def message_box(text, *options, hwnd: nil, caption: nil)
        options = options.map { |o| o.is_a?(Symbol) ? User32::MessageBoxFlag[o] : o }.reduce(0, &:|)
        User32::DialogBoxCommandID[User32.MessageBox(hwnd, text.to_w, caption.to_w, options)]
      end

      def info_box(text, *options, hwnd: nil, caption: nil)
        message_box(text, *options, :ICONINFORMATION, hwnd: hwnd, caption: caption)
      end

      def error_box(text, *options, hwnd: nil, caption: nil)
        message_box(text, *options, :ICONERROR, hwnd: hwnd, caption: caption)
      end

      def warning_box(text, *options, hwnd: nil, caption: nil)
        message_box(text, *options, :ICONWARNING, hwnd: hwnd, caption: caption)
      end

      def question_box(text, *options, hwnd: nil, caption: nil)
        message_box(text, *options, :ICONQUESTION, hwnd: hwnd, caption: caption)
      end

      def yes_no_box(text, *options, hwnd: nil, caption: nil)
        options += [:YESNO]
        message_box(text, *options, :ICONQUESTION, hwnd: hwnd, caption: caption)
      end
    end
  end
end
