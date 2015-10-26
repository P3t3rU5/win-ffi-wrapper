require 'win-ffi/functions/user32/controls/button'

module WinFFIWrapper
  class Window
    def add_radiobutton(radiobutton)
      # raise ArgumentError if
      add_control(radiobutton)
    end
  end

  class RadioGroup

    include Ducktape::Hookable

    def_hooks :on_change

    attr_accessor :window

    def initialize(window, &block)
      @window = window
      @buttons = []
      yield self if block_given?
    end

    def activate(index)
      @option = @buttons[index]
      User32::CheckRadioButton(@window.hwnd, @buttons[0].id, @buttons[-1].id, @buttons[index].id)
    end

    def add_radiobutton(radiobutton)
      radiobutton.first = true if @buttons.empty?
      window.add_control(radiobutton)
      @buttons << radiobutton
    end

    def add_radiobuttons(*radiobuttons)
      raise ArgumentError unless radiobuttons.all? { |rb| rb.is_a?(RadioButton) }
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

    def ===(other)

    end
  end

  class RadioButton
    include Control

    attr_accessor :first

    bindable :text,
             default: 'Radio Button'

    bindable :notify,
             default: true,
             validate: [true, false]

    bindable :alignment,
             default: :left

    def initialize(group, &block)
      raise ArgumentError unless group.is_a?(RadioGroup)
      @group = group
      super(group.window, 'button', &block)
      @first = false
    end

    def create_style
      style = [
          @first && :GROUP,
          @first && :TABSTOP
      ].select { |flag| flag } # removes falsey elements

      style.map { |v| User32::WindowStyle[v] }.reduce(0, &:|) | User32::ButtonControlStyle[:RADIOBUTTON] | super
    end

    def bn_clicked
      @group.activate(@group.get_index(self))
      self.send(:call_hooks, :on_click)
      @group.send(:call_hooks, :on_change, index: @group.get_index(self))
    end

    def bn_doubleclicked
      self.send(:call_hooks, :on_doubleclick)
    end
  end
end