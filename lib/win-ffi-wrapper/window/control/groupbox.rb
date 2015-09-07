module WinFFIWrapper
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
  end
end