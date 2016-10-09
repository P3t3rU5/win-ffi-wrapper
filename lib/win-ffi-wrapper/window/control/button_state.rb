require 'win-ffi/user32/enum/window/control/button/button_state'

module WinFFIWrapper
  module ButtonState
    def self.included(m)
      m.bindable :has_indeterminate_state,
               default: false,
               validate: [true, false]

      m.bindable :state,
                 default: false,
                 validate: [true, false, :indeterminate],
                 setter: ->(value) do
                   set_value :state, value do
                     if @handle
                       send_message(:SETCHECK, User32::ButtonState[case value
                                                                   when true
                                                                     :CHECKED
                                                                   when false
                                                                     :UNCHECKED
                                                                   when :indeterminate
                                                                     :INDETERMINATE
                                                                   end], 0)
                     end
                     call_hooks :on_change
                   end
                 end

      m.def_hooks :on_change
    end

    def initialize(window, &block)
      super(window, &block)
      window.on_loaded do
        send_message(:SETCHECK, User32::ButtonState[case self.state
                                                    when true
                                                      :CHECKED
                                                    when false
                                                      :UNCHECKED
                                                    when :indeterminate
                                                      :INDETERMINATE
                                                    end], 0)
      end
    end

    private
    def clicked
      set_value :state, if has_indeterminate_state
        case get_value(:state)
        when true
          :indeterminate
        when :indeterminate
          false
        when false
          true
        end
      else
        !self.state
      end
      call_hooks(:on_click)
      call_hooks(:on_change)
    end
  end
end