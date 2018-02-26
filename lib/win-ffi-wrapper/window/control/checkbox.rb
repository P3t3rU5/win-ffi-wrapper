require 'win-ffi/user32/enum/window/state/button_state'
require 'win-ffi/user32/enum/window/message/button_message'

require 'win-ffi-wrapper/window/control/button_state'

module WinFFIWrapper
  class Window
    def add_checkbox(button)
      raise ArgumentError unless button.is_a?(CheckBox)
      add_control(button)
    end
  end

  class CheckBox < Button
    include ButtonState

    bindable :text,
             default: 'CheckBox'

    bindable :alignment,
             default: :left

    bindable :text_position,
             default: :right,
             validate: [:right, :left]

    def is_checked?
      get_check == :CHECKED
    end

    def is_unchecked?
      get_check == :UNCHECKED
    end

    def is_indeterminate?
      get_check == :INDETERMINATE
    end

    alias_method :checked?, :is_checked?
    alias_method :unchecked?, :is_unchecked?
    alias_method :indeterminate?, :is_indeterminate?

    private
    def create_window_style
      style = [
          has_indeterminate_state ? :AUTO3STATE : :AUTOCHECKBOX,
          text_position == :left ? :LEFT_TEXT : false
      ].select { |flag| flag }
      style.map { |v| User32::ButtonControlStyle[v] }.reduce(0, &:|) | super
    end
  end
end