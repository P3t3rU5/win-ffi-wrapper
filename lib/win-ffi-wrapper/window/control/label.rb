module WinFFIWrapper
  class Label
    include Control

    bindable :text,
             default: 'Label'

    bindable :alignment,
             default: :left

    bindable :vertical_alignment,
             default: :top

    def initialize(window, &block)
      super(window, 'static', &block)
    end

    private
    def create_style
      style = [
          alignment.upcase
      ].select { |flag| flag } # removes falsey elements

      style.map { |v| User32::StaticControlStyle[v] }.reduce(0, &:|) | super
    end
  end
end