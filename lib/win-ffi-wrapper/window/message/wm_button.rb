require 'win-ffi/user32/enum/interaction/mouse/mouse_keys_state'

module WinFFIWrapper
  class Window
    # wParam - Indicates whether various virtual keys are down.
    %w'l m r'.each do |btn|
      %w'down dblclk up'.each do |mode|
        event = "on_#{btn}mouse#{mode}"
        name = "#{btn}button#{mode}"
        private define_method name, ->(params) do
          flags = User32::MouseKeysState.symbols
          flags.map! { |f| [f, (params.wparam & User32::MouseKeysState[f]) != 0] }
          flags = Hash[flags]
          puts_msg name.upcase, params.hwnd, flags, "with x = #{mousex} y = #{mousey}"
          call_hooks(event, flags)
          0
        end
      end
    end
  end
end