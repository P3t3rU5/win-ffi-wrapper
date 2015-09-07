using WinFFIWrapper::StringUtils

module WinFFIWrapper
  class ComboBox
    include Control

    bindable :autosort,
             default: true,
             validate: [true, false]

    def initialize(window, &block)
      super(window, 'combobox', &block)
    end

    def populate(*args)
      args.each do |item|
        User32.SendMessageW(@handle, ComboBoxMessage[:ADDSTRING], 0, item.to_w)
      end
    end

    private
    def create_style
      style = [
          autosort && :SORT,

      ].select { |flag| flag }
      style.map { |v| User32::ComboBoxStyle[v] }.reduce(0, &:|) | super
    end
  end
end