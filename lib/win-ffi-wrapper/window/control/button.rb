require 'win-ffi/user32/enum/window/control/button/button_notification'
require 'win-ffi/user32/enum/window/control/button/button_message'
require 'win-ffi/user32/enum/window/control/button/button_state'

require 'win-ffi-wrapper/window/control/base_control'

module WinFFIWrapper
  class Window
    def add_button(button)
      raise ArgumentError unless button.is_a?(Button)
      add_control(button)
    end
  end

  class Button
    include WinFFIWrapper::Control

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

    def command(command)
      case User32::ButtonNotification[command]
      when :CLICKED
        clicked
        'CLICKED'
      when :DBLCLK
        double_clicked
        'DOUBLECLICKED'
      when :DISABLE
        disabled
        'DISABLE'
      when :PUSHED
        pushed
        'PUSHED'
      when :SETFOCUS
        set_focus
        'SETFOCUS'
      when  :KILLFOCUS
        kill_focus
        'KILLFOCUS'
      when :HOTITEMCHANGE
        hot_item_change
        'HOTITEMCHANGE'
      when :UNPUSHED
        unpushed
        'UNPUSHED'
      end
    end

    def click
      send_message(:CLICK)
    end

    def get_check
      User32::ButtonState[send_message(:GETCHECK)]
    end

    def set_check(check)
      send_message(:SETCHECK, User32::ButtonState[check.upcase.to_sym])
    end

    def get_icon
      send_message(:GETIMAGE, User32::Image[:ICON])
    end

    def set_icon(icon)
      send_message(:SETIMAGE, User32::Image[:ICON], icon)
    end

    def get_bitmap
      send_message(:GETIMAGE, User32::Image[:BITMAP])
    end

    def set_bitmap(bitmap)
      send_message(:SETIMAGE, User32::Image[:BITMAP], bitmap)
    end

    def get_state
      User32::ButtonState[send_message(:GETSTATE)]
    end

    def set_state(state)
      send_message(:SETSTATE,  User32::ButtonState[state])
    end

    def set_style(style)
      send_message(:SETSTYLE, style)
    end

    alias_method :check,  :get_check
    alias_method :check=, :set_check
    alias_method :state,  :get_state
    alias_method :state=, :get_state

    private
    def create_window_style
      style = [
          push && :DEFPUSHBUTTON,
          notify && :NOTIFY,
          alignment.upcase,
          vertical_alignment == :center ? :VCENTER : vertical_alignment.upcase
      ].select { |flag| flag }.map do |v|
        User32::ButtonStyle[v]
      end.reduce(0, &:|) | super

      style
    end

    def send_message(message, wparam = 0, lparam = 0)
      User32.SendMessage(@handle, User32::ButtonMessage[message], wparam, lparam) if @handle
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