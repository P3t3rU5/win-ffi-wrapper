require_relative '../../rect'
require_relative '../../screen'

require 'win-ffi/user32/struct/window/window/window_pos'

module WinFFIWrapper
  class Window
    def wm_windowposchanging(params)
      pos = User32::WINDOWPOS.new(FFI::Pointer.new(params.lparam))

      puts_msg :WM_WINDOWPOSCHANGING, params.hwnd, nil, pos

      placement = User32::WINDOWPLACEMENT.new
      User32.GetWindowPlacement(@hwnd, placement)
      #puts "\t\tWindowPlacement -> #{placement}"

      return 0 if @initialized

      #first call of this message
      @initialized = true

      r = rect
      mode = center_mode
      mode = :screen if mode == :owner and owner.nil?

      p = placement.rcNormalPosition
      r.width  ||= p.width
      r.height ||= p.height

      if mode == :manual
        r.left ||= p.left
        r.top  ||= p.top
      else
        r.center = if mode == :owner and owner.state == :minimized
                     p = User32::WindowPlacement.new
                     User32.GetWindowPlacement(owner.instance_variable_get(:@hwnd), p)
                     p = p.rcNormalPosition
                     [p.left + p.width/2, p.top + p.height/2]
                   else
                     mode == :owner ? owner.absolute_center : Screen.center
                   end
      end

      if self.state == :restored
        User32.MoveWindow(@hwnd, r.left, r.top, r.width, r.height, true)
      else
        %w'left top width height'.each{ |n| placement.rcNormalPosition.send("#{n}=", r.send(n)) }
        User32.SetWindowPlacement(@hwnd, placement)
      end
      0
    end
    private :wm_windowposchanging
  end
end