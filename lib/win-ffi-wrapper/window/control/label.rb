require 'win-ffi/user32/enum/image'
require 'win-ffi/user32/enum/window/message/static_message'
require 'win-ffi/user32/enum/window/style/static_style'
require 'win-ffi/user32/enum/window/notification/static_notification'

module WinFFIWrapper
  class Window
    def add_label(label)
      raise ArgumentErro unless label.is_a? Label
      add_control(label)
    end

    def add_labels(*labels)
      labels.each do |label|
        add_label(label)
      end
    end
  end

  class Label
    include Control

    bindable :text,
             default: 'Label'

    bindable :alignment,
             default: :left

    bindable :vertical_alignment,
             default: :top

    bindable :icon,
             default: nil,
             validate: [Icon, nil],
             getter: -> () do
               send_message(:GETICON, 0, 0)
             end,
             setter: -> (value) do
               set_value :icon, value
               send_message(:SETICON, value, 0)
             end

    bindable :image_type,
             default: nil,
             validate: [:bitmap, :icon, :enhmetafile, :cursor, nil]

    bindable :image,
             default: nil,
             validate: [Integer, nil],
             getter: -> () do
               send_message(:GETIMAGE, 0, 0)
             end,
             setter: -> (value) do
               set_value :image, value
               send_message(:SETIMAGE, User32::Image[image_type.upcase], value)
             end

    def initialize(window, &block)
      super(window, 'static', &block)
      window.on_loaded do
        send_message(:SETICON, get_value(:icon).handle.address, 0) if get_value(:icon)
        send_message(:SETIMAGE, User32::Image[image_type && image_type.upcase].to_i, get_value(:image).to_i)
      end
    end

    def command(params)
      case params
      when User32::StaticNotification[:CLICKED]
        clicked
        'CLICKED'
      when User32::StaticNotification[:DBLCLK]
        doubleclicked
        'DOUBLECLICKED'
      when User32::StaticNotification[:ENABLED]
        enabled
        'ENABLED'
      when User32::StaticNotification[:DISABLED]
        disabled
        'DISABLED'
      end
    end

    private
    def create_window_style
      style = [
          alignment.upcase,
          image_type && image_type.upcase,
          get_value(:icon) && :ICON,
          :NOTIFY
      ].select { |flag| flag } # removes falsey elements

      style.map { |v| User32::StaticStyle[v] }.reduce(0, &:|) | super
    end

    def send_message(message, wparam, lparam)
      User32.SendMessage(@handle, User32::StaticMessage[message], wparam, lparam) if @handle
    end
  end
end