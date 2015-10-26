module WinFFIWrapper
  class Window
    def add_listbox(listbox)
      raise ArgumentError unless listbox.is_a?(ListBox)
      add_control(listbox)
    end
  end

  class ListBox
    include Control

    bindable :items,
             validate: Array

    bindable :combobox,
             validate: [true, false]

    def initialize(window, &block)
      super(window, 'listbox', &block)
    end

    def create_style
      style = [

      ].select { |flag| flag }
      style.map { |v| User32::ListBoxStyle[v] }.reduce(0, &:|) | super
    end

  end
end