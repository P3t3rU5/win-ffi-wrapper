require 'win-ffi/user32/enum/window/control/button/button_style'

module WinFFIWrapper
  class Window
    def add_groupbox(groupbox)
      raise ArgumentError unless groupbox.is_a?(GroupBox)
      add_control(groupbox)
    end
  end

  class GroupBox
    include Control

    bindable :text,
             default: 'Group'

    def initialize(window, &block)
      super(window, "button", &block)
    end

    private
    def create_window_style
      User32::ButtonStyle[:GROUPBOX] || super
    end

    def create_window_style_extended
      User32::WindowStyleExtended[:TRANSPARENT]
    end
  end
end