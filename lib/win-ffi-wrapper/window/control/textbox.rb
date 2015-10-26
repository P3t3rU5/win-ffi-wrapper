using WinFFIWrapper::StringUtils

require 'win-ffi-wrapper/window/control/base_control'
require 'win-ffi/enums/user32/window/style/edit_style'
require 'win-ffi/functions/user32/window/window'
require 'win-ffi/functions/user32/keyboard'


module WinFFIWrapper
  class TextBox
    include Control, WinFFI

    bindable :text,
             default: '',
             validate: String,
             coerce: ->(_, value) { value.to_w }

    bindable :multiline,
             default: false,
             validate: [true, false]

    bindable :input_type,
             default: :all,
             validate: [:all, :password, :number, :lowercase, :uppercase]

    bindable :autohscroll,
             default: false,
             validate: [true, false]

    bindable :autovscroll,
             default: false,
             validate: [true, false]

    bindable :is_readonly?,
             default: false,
             validate: [true, false]

    bindable :alignment,
             default: :left

    def initialize(window, &block)
      super(window, 'edit', &block)
      User32.EnableWindow(@handle, true)
      on_click do
        User32.SetFocus(@handle)
      end
    end

    private
    def create_style
      edit_style = [
          alignment.upcase,
          input_type == :all ? false : input_type.uppercase,
          multiline    && :MULTILINE,
          autohscroll  && :AUTOHSCROLL,
          autovscroll  && :AUTOVSCROLL,
          is_readonly? && :READONLY
      ].select { |flag| flag } # removes falsey elements
      vertical_alignment = [:TOP, :VCENTER, :BOTTOM].map { |v| User32::ButtonControlStyle[v] }.reduce(0, &:|)
      edit_style.map { |v| User32::EditStyle[v] }.reduce(0, &:|) | super & ~(vertical_alignment)
    end

    def create_style_ex
      User32::WindowStyleEx[:CLIENTEDGE] | super
    end

    def en_change
      # User32.SetWindowTextW(@hwnd, params[:value].to_w)
      text_size = User32.GetWindowTextLengthW(@handle) + 1
      FFI::MemoryPointer.new(:ushort, text_size) do |text|
        User32.GetWindowTextW(@handle, text, text_size)
        text = text.read_array_of_uint16(text_size - 1).pack('U*')
        set_value :text, text
      end
    end

    def method_missing(m, *args)
      text.send(:m, *args) if String.new.respond_to?(:m)
    end
  end

  class Window
    def add_textbox(textbox)
      raise ArgumentError unless textbox.is_a?(TextBox)
      add_control(textbox)
    end
  end
end