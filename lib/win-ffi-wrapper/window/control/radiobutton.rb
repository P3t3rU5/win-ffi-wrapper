require 'win-ffi/user32/function/control/button'

module WinFFIWrapper
  class Window
    def add_radiogroup(radiogroup)
      raise ArgumentError unless radiogroup.is_a? RadioGroup
      add_control(radiogroup)
    end
  end

  class RadioGroup
    include Ducktape::Hookable, Control

    def_hooks :on_change

    attr_accessor :window

    def initialize(window, &block)
      @window = window
      @buttons = []
      yield(self) if block_given?
    end

    def activate(index)
      @option = @buttons[index]
      User32.CheckRadioButton(@window.hwnd, @buttons[0].id, @buttons[-1].id, @buttons[index].id)
    end

    def add_radiobutton(radiobutton)
      raise ArgumentError unless radiobutton.is_a? RadioButton
      radiobutton.first = true if @buttons.empty?
      window.add_control(radiobutton)
      @buttons << radiobutton
    end

    def add_radiobuttons(*radiobuttons)
      radiobuttons.each do |rb|
        add_radiobutton(rb)
      end
    end

    def get_index(radiobutton)
      @buttons.index(radiobutton)
    end

    # def remove_radiobutton(radiobutton)
    #   @buttons.delete(radiobutton)
    #   window.
    # end
  end

  class RadioButton < Button
    # include ButtonState

    attr_accessor :first

    bindable :text,
             default: 'Radio Button'

    bindable :alignment,
             default: :left

    def initialize(group, &block)
      raise ArgumentError unless group.is_a?(RadioGroup)
      @group = group
      super(group.window, &block)
      @first = false
    end

    private
    def create_window_style
      style = [
          @first && :GROUP,
          @first && :TABSTOP
      ].select { |flag| flag } # removes falsey elements

      style.map { |v| User32::WindowStyle[v] }.reduce(0, &:|) | User32::ButtonControlStyle[:RADIOBUTTON] | super
    end

    def clicked
      @group.activate(@group.get_index(self))
      super
      @group.send(:call_hooks, :on_change, index: @group.get_index(self))
    end
  end
end