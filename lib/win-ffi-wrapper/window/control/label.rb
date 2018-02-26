require 'win-ffi/user32/enum/resource/image'
require 'win-ffi/user32/enum/window/control/static/static_message'
require 'win-ffi/user32/enum/window/control/static/static_style'
require 'win-ffi/user32/enum/window/control/static/static_notification'

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

    def get_bitmap
      send_message(:GETIMAGE, User32::Image[:BITMAP])
    end

    def set_bitmap(bitmap)
      send_message(:SETIMAGE, User32::Image[:BITMAP], bitmap)
    end

    def get_icon
      send_message(:GETIMAGE, User32::Image[:ICON])
    end

    def set_icon(icon)
      send_message(:SETIMAGE, User32::Image[:ICON], icon)
    end

    def get_cursor
      send_message(:GETIMAGE, User32::Image[:CURSOR])
    end

    def set_cursor(cursor)
      send_message(:SETIMAGE, User32::Image[:CURSOR], cursor)
    end

    def get_enhmetafile
      send_message(:GETIMAGE, User32::Image[:ENHMETAFILE])
    end

    def set_enhmetafile(enhmetafile)
      send_message(:SETIMAGE, User32::Image[:ENHMETAFILE], enhmetafile)
    end

    alias_method :bitmap,  :get_bitmap
    alias_method :bitmap=, :set_bitmap
    alias_method :icon,    :get_icon
    alias_method :icon=,   :set_icon
    alias_method :cursor,  :get_cursor
    alias_method :cursor=, :set_cursor
    alias_method :enhmetafile,  :get_enhmetafile
    alias_method :enhmetafile=, :set_enhmetafile

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

    def send_message(message, wparam = 0, lparam = 0)
      User32.SendMessage(@handle, User32::StaticMessage[message], wparam, lparam) if @handle
    end
  end
end