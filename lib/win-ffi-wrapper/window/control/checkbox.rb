

module WinFFIWrapper
  class Window
    def add_checkbox(button)
      raise ArgumentError unless button.is_a?(CheckBox)
      add_control(button)
    end
  end

  class CheckBox
    include Control

    bindable :text,
             default: 'CheckBox'

    bindable :has_indeterminate_state,
             default: false,
             validate: [true, false]

    bindable :alignment,
             default: :left

    bindable :text_position,
             default: :right,
             validate: [:right, :left]

    bindable :value,
             default: false,
             validate: [true, false, :indeterminate]
             # setter: ->(value) do
             #   set_value :text, value do
             #     User32.SetWindowTextW(@handle, value.to_w)
             #   end
             # end

    def_hooks :on_change

    def initialize(window, &block)
      super(window, 'button', &block)
    end

    def create_style
      style = [
          has_indeterminate_state ? :AUTO3STATE : :AUTOCHECKBOX,
          text_position == :left ? :LEFT_TEXT : false
          # :CHECKBOX
      ].select { |flag| flag }
      style.map { |v| User32::ButtonControlStyle[v] }.reduce(0, &:|) | super
    end

    private
    def bn_clicked
      call_hooks(:on_click)
      call_hooks(:on_change)
      self.value = !self.value
    end
  end
end