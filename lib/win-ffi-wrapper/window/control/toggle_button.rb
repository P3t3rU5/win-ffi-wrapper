require 'win-ffi-wrapper/window/control/button'
require 'win-ffi-wrapper/window/control/button_state'

module WinFFIWrapper
  class Window
    def add_toggle_button(toggle_button)
      raise ArgumentError unless toggle_button.is_a?(ToggleButton)
      add_control(toggle_button)
    end
  end

  class ToggleButton < Button
    include ButtonState

    bindable :text,
             default: 'ToggleButton'

    private
    def create_window_style
      [
          :AUTOCHECKBOX, :PUSHLIKE
      ].select { |flag| flag }.map do |v|
        User32::ButtonControlStyle[v]
      end.reduce(0, &:|) | super
    end
  end
end