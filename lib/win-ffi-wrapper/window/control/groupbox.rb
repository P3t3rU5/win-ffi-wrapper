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
    def create_style
      User32::ButtonControlStyle[:GROUPBOX] | super
    end

    def create_style_ex
      User32::WindowStyleEx[:TRANSPARENT]
    end
  end
end