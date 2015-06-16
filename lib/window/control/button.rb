module WinFFIWrapper
  class Button
    include Control

    bindable :text,
             default: 'Button'

    bindable :push,
             default: false,
             validate: [true, false]

    def initialize(window, &block)
      super(window, 'button', &block)
    end

    def create_style
      style = [
          push && :DEFPUSHBUTTON
      ].select { |flag| flag }
      style.map { |v| User32::ButtonControlStyle[v] }.reduce(0, &:|) | super
    end
  end

  class Window
    def add_button(button)
      add_control(button)
    end
  end
end