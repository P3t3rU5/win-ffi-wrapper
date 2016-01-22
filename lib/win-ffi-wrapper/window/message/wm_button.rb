module WinFFIWrapper
  class Window
    # wParam - Indicates whether various virtual keys are down.
    %w'l m r'.each do |btn|
      %w'down dblclk up'.each do |mode|
        event = "on_#{btn}mouse#{mode}"
        name = "wm_#{btn}button#{mode}"
        define_method name, ->(params) do
          flags = User32::MouseKeysFlags.symbols
          flags.map! { |f| [f, (params.wparam & User32::MouseKeysFlags[f]) != 0] }
          flags = Hash[flags]
          puts_msg name.upcase, params.hwnd, flags, "with x = #{mousex} y = #{mousey}"
          # puts "#{event} with x = #{mousex} y = #{mousey}"
          call_hooks(event, flags)
          0
        end
        private name
      end
    end
  end
end