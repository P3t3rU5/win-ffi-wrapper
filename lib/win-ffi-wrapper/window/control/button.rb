require 'win-ffi/user32/enum/window/notification/button_notification'
require 'win-ffi/user32/enum/window/message/button_message'

module WinFFIWrapper
  class Window
    def add_button(button)
      raise ArgumentError unless button.is_a?(Button)
      add_control(button)
    end
  end

  class Button
    include Control

    bindable :text,
             default: 'Button'

    bindable :notify,
             default: true,
             validate: [true, false]

    bindable :push,
             default: false,
             validate: [true, false]

    def_hooks :on_pushed, :on_unpushed

    def initialize(window, &block)
      super(window, 'button', &block)
    end

    def command(param)
      case param
      when User32::ButtonNotification[:CLICKED]
        clicked
        'CLICKED'
      when User32::ButtonNotification[:DBLCLK]
        double_clicked
        'DOUBLECLICKED'
      when User32::ButtonNotification[:DISABLED]
        disabled
        'DISABLED'
      when User32::ButtonNotification[:PUSHED]
        pushed
        'PUSHED'
      when User32::ButtonNotification[:SETFOCUS]
        set_focus
        'SETFOCUS'
      when  User32::ButtonNotification[:KILLFOCUS]
        kill_focus
        'KILLFOCUS'
      when User32::ButtonNotification[:HOTITEMCHANGE]
        hot_item_change
        'HOTITEMCHANGE'
      when User32::ButtonNotification[:UNPUSHED]
        unpushed
        'UNPUSHED'
      end
    end

    def click
      send_message(:CLICK, 0, 0)
    end

    private
    def create_window_style
      [
          push && :DEFPUSHBUTTON,
          notify && :NOTIFY,
          alignment.upcase,
          vertical_alignment == :center ? :VCENTER : vertical_alignment.upcase
      ].select { |flag| flag }.map do |v|
        User32::ButtonStyle[v]
      end.reduce(0, &:|) | super
    end

    def send_message(message, wparam, lparam)
      User32.SendMessage(@handle, User32::ButtonMessage[message], wparam, lparam)
    end

    def hot_item_change
      #TODO
    end

    def pushed
      call_hooks :on_pushed
    end

    def unpushed
      call_hooks :on_unpushed
    end
  end
end