require 'win-ffi/comctl32'
require 'win-ffi/comctl32/struct/window/control/progressbar/range'

require 'win-ffi/comctl32/enum/window/control/progressbar/message'

module WinFFIWrapper
  class Window
    def add_progressbar(progressbar)
      add_control(progressbar) if progressbar.is_a?(ProgressBar)
    end
  end

  class ProgressBar
    include Control

    bindable :value,
             default: 0,
             validate: Integer,
             setter: ->(value) do
               set_value :value, value do
                 send_message(:SETPOS, value, 0)
               end
             end,
             getter: ->() do
               send_message(:GETPOS, 0, 0)
             end

    bindable :range,
             default: 0..100,
             validate: Range,
             setter: ->(value) do
               set_value :range, value do
                 send_message(:SETRANGE32, value.first, value.last)
               end
             end,
             getter: ->() do
               pbr = User32::PBRANGE.new()
               send_message(:GETRANGE, 0, pbr.pointer.address)
               pbr.iLow..pbr.iHigh
             end

    def_hooks :on_loaded

    def initialize(window, &block)
      super(window, Comctl32::PROGRESS_CLASS, &block)
      window.on_loaded do
        range = get_value :range
        send_message(:SETRANGE32, range.first, range.last)
        send_message(:SETPOS, get_value(:value), 0)
      end
    end

    def +(delta)
      send_message(:DELTAPOS, delta, 0)
    end

    def minimum
      range.first
    end

    def maximum
      range.last
    end

    alias_method :min, :minimum
    alias_method :max, :maximum

    private
    def create_window_style
      super
    end

    def create_window_style_extended
      0
    end

    def send_message(message, wparam, lparam)
      User32.SendMessage(@handle, Comctl32::ProgressBarMessage[message], wparam, lparam) if @handle
    end
  end
end