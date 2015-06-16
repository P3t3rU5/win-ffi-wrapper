module WinFFIWrapper
  class CheckBox
    include Control

    bindable :text,
             default: 'CheckBox'

    bindable :has_indeterminate_state,
             default: false,
             validate: [true, false]

    bindable :text_position,
             default: :right,
             validate: [:right, :left]

    def initialize(window, &block)
      super(window, 'button', &block)
      yield if block_given?
    end

    def create_style
      style = [
          has_third_state ? :AUTOCHECKBOX : :AUTO3STATE,
          text_position == :left ? :LEFT_TEXT : false
      ].select { |flag| flag }
      style.map { |v| User32::ButtonControlStyle[v] }.reduce(0, &:|) | super
    end
  end
end