module WinFFIWrapper
  class Window
    def add_button(button)
      raise ArgumentError unless button.is_a?(Button)
      add_control(button)
    end
  end

  class Button
    include Control

    bindable :text,
             default: 'Button'

    bindable :notify,
             default: true,
             validate: [true, false]

    bindable :push,
             default: false,
             validate: [true, false]

    def initialize(window, &block)
      super(window, 'button', &block)
    end

    def create_style
      style = [
          push && :DEFPUSHBUTTON,
          notify && :NOTIFY
      ].select { |flag| flag }
      style.map { |v| User32::ButtonControlStyle[v] }.reduce(0, &:|) | super
    end
  end

  def bn_clicked
    self.send(:call_hooks, :on_click)
  end

  def bn_doubleclicked
    self.send(:call_hooks, :on_doubleclick)
  end
end