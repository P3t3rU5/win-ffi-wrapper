require 'win-ffi-wrapper/window/control/listbox'

using WinFFIWrapper::StringUtils

module WinFFIWrapper
  class ComboBox
    include Control

    bindable :autosort,
             default: true,
             validate: [true, false]

    bindable :type,
             default: :simple,
             validate: [:simple, :dropdown, :dropdownlist]

    def initialize(window, &block)
      super(window, 'combobox', &block)
    end

    # def populate(*args)
    #   args.each do |item|
    #     send_message(:ADDSTRING, 0, item.to_w)
    #   end
    # end

    private
    def create_window_style
      style = [
          autosort && :SORT,
          type.upcase
      ].select { |flag| flag }
      style.map { |v| User32::ComboBoxStyle[v] }.reduce(0, &:|) | super
    end

    private
    def send_message(message, wparam, lparam)
      User32.SendMessage(@handle, ComboBoxMessage[message], wparam, lparam) if handle
    end
  end
end