using WinFFI::StringUtils
using WinFFI::BooleanUtils

require 'pathname'
require 'facets/pathname'
require 'facets/ostruct'
require 'set'
require 'ducktape'
require 'logger'

require 'win-ffi/user32/enum/window/message/window_message'
require 'win-ffi/user32/enum/color_type'
require 'win-ffi/user32/enum/resource/icon/icon_type'
require 'win-ffi/comctl32/enum/window/control/init_common_controls'

require 'win-ffi/user32/function/desktop_aplication'
require 'win-ffi/user32/function/window/window'
require 'win-ffi/user32/function/window/message'
require 'win-ffi/user32/function/painting_drawing'
require 'win-ffi/comctl32/function/window/control'
require 'win-ffi/kernel32/function/activation'
require 'win-ffi/user32/function/resource/cursor'
require 'win-ffi/user32/function/device_context'
require 'win-ffi/user32/function/window/control/scrollbar'

require 'win-ffi/comctl32/struct/window/control/init_common_controls_ex'
require 'win-ffi/kernel32/struct/actctx'
require 'win-ffi/user32/struct/window/window_class/wndclassex'
require 'win-ffi/user32/struct/configuration/non_client_metrics'
require 'win-ffi/user32/struct/window/control/scrollbar/scroll_info'

require 'win-ffi/core/macro/util'

# Wrappers
require 'win-ffi-wrapper/device_context'
require 'win-ffi-wrapper/resource'
require 'win-ffi-wrapper/resource/icon'
require 'win-ffi-wrapper/resource/font'
require 'win-ffi-wrapper/resource/cursor'
require 'win-ffi-wrapper/kernel/dll'
require 'win-ffi-wrapper/dialog'
require 'win-ffi-wrapper/window/control/base_control'

(Pathname[__dir__] / 'window/message').visit { |f| require f }

module WinFFIWrapper
  class Window # < Control
    # https://msdn.microsoft.com/en-us/library/windows/desktop/ms632599(v=vs.85).aspx#overlapped
    include Ducktape::Bindable, Ducktape::Hookable, WinFFI

    bindable :title,
             default: '',
             coerce: ->(_, value) do
               value.to_w
             end,
             validate: String,
             setter: (->(value) do
               set_value(:title, value) do |v|
                 @hwnd ? User32.SetWindowText(@hwnd, v) : on_loaded { self.title = value }
               end
             end)

    bindable :enabled,
             default: true,
             validate: [true, false],
             setter: (->(value) do
               set_value(:enabled, value) do |v|
                 with_handle { User32.EnableWindow(@hwnd, v) }
               end
             end)

    bindable :visible,
             access: :readonly,
             default: false,
             validate: [true, false],
             getter: (->() { User32.IsWindowVisible(@hwnd) } )

    bindable :mousex,
             access: :readonly,
             default: 0,
             validate: Integer

    bindable :mousey,
             access: :readonly,
             default: 0,
             validate: Integer

    bindable :center_mode,
             default:  :manual,
             validate: [:owner, :screen, :manual]

    bindable :height,
             default: User32::CW_USEDEFAULT,
             validate: Integer,
             setter: ->(value) { set_value(:height, value) { moved(:height, value) } }

    bindable :width,
             default: User32::CW_USEDEFAULT,
             validate: Integer,
             setter: ->(value) { set_value(:width, value) { moved :width, value } }

    bindable :left,
             default: User32::CW_USEDEFAULT,
             validate: Integer,
             setter: ->(value) { set_value(:left, value) { moved :left, value } }

    bindable :top,
             default: User32::CW_USEDEFAULT,
             validate: Integer,
             setter: ->(value) { set_value(:top, value) { moved :top, value } }

    bindable :max_height,
             validate: [Integer, nil] #TODO not working yet

    bindable :min_height,
             validate: [Integer, nil] #TODO not working yet

    bindable :max_width,
             validate: [Integer, nil] #TODO not working yet

    bindable :min_width,
             validate: [Integer, nil] #TODO not working yet

    bindable :focused_control,
             default: nil,
             validate: [Control, nil],
             setter: (->(value) { set_value(:focused_control, value) { User32.SetFocus(value.handle) } })

    bindable :client_rect,
             access: :readonly,
             validate: Rect,
             default: ->() { Rect.new },
             getter: ->() { get_value(:client_rect).dup }

    bindable :icon,
             default: Icon.sample,
             validate: [Icon, nil],
             setter: ->(value) do
               self.taskbar_icon     = value
               self.application_icon = value
             end

    bindable :taskbar_icon,
             default: Icon.sample,
             validate: [Icon, nil],
             setter: ->(value) do
               set_value :taskbar_icon, value do
                 value = Icon.sample if value.nil?
                 send_message(:SETICON, User32::IconType[:BIG], value.hicon.address)
               end
             end

    bindable :application_icon,
             default: Icon.sample,
             validate: [Icon, nil],
             setter: ->(value) do
               set_value :taskbar_icon, value do
                 send_message(:SETICON, User32::IconType[:SMALL], value.hicon.address)
               end
             end

    bindable :cursor,
             default: Cursor.arrow,
             validate: [Cursor, nil],
             setter: ->(value) { set_value(:cursor, value) { User32.SetCursor(value.hcursor) } }

    bindable :state,
             default:  :restored,
             validate: [:restored, :minimized, :maximized],
             setter: ->(value) do
               set_value :state, value do
                 value = value.to_s.chop.to_sym
                 call_hooks "on_before_#{value}"
                 User32.ShowWindow(@hwnd, value.upcase)
                 User32.InvalidateRect(@hwnd, nil, true)
                 update_window
                 call_hooks "on_after_#{value}"
               end
             end


    # WindowClassStyle
    bindable :can_close,
             default:  true,
             validate: [true, false],
             setter: ->(value) do
               set_value :can_close, value do
                 with_handle { User32.SetClassLong(@hwnd, :STYLE, (User32.GetClassLong(@hwnd, :STYLE) & ~User32::WindowClassStyle[:NOCLOSE]) | (value ? 0 : User32::WindowClassStyle[:NOCLOSE])) }
               end
             end

    bindable :has_shadow,
             default:  false,
             validate: [true, false],
             setter: ->(value) do
               set_value :has_shadow, value do
                 with_handle do User32.SetClassLong(@hwnd, :STYLE,
                                     (User32.GetClassLong(@hwnd, :STYLE) & ~User32::WindowClassStyle[:DROPSHADOW]) |
                                         (value ? User32::WindowClassStyle[:DROPSHADOW] : 0))
                 end
               end
             end

    # WindowStyle
    bindable :can_maximize,
             default:  true,
             validate: [true, false],
             setter: ->(value) do
               set_value :can_maximize, value do
                 with_handle { User32.SetWindowLong(@hwnd, :STYLE, (User32.GetWindowLong(@hwnd, :STYLE) & ~User32::WindowStyle[:MAXIMIZEBOX]) | (value ? User32::WindowStyle[:MAXIMIZEBOX] : 0)) }
               end
             end

    bindable :can_minimize,
             default:  true,
             validate: [true, false],
             setter: ->(value) do
               set_value :can_minimize, value do
                 with_handle { User32.SetWindowLong(@hwnd, :STYLE, (User32.GetWindowLong(@hwnd, :STYLE) & ~User32::WindowStyle[:MINIMIZEBOX]) | (value ? User32::WindowStyle[:MINIMIZEBOX] : 0)) }
               end
             end

    bindable :can_resize,
             default:  true,
             validate: [true, false],
             setter: ->(value) do
               set_value :can_resize, value do
                 with_handle { User32.SetWindowLong(@hwnd, :STYLE, (User32.GetWindowLong(@hwnd, :STYLE) & ~User32::WindowStyle[:SIZEBOX]) | (value ? User32::WindowStyle[:SIZEBOX] : 0)) }
               end
             end

    bindable :has_context_help,
             default: false,
             validate: [true, false],
             setter: ->(value) do
               set_value :has_context_help, value do
                 # User32.SetWindowLong(@hwnd, :STYLE, (User32.GetWindowLong(@hwnd, :STYLE) & ~User32::WindowStyle[:SIZEBOX]) | value ? User32::WindowStyle[:SIZEBOX] : 0)
               end
             end

    bindable :has_horizontal_scroll,
             default:  false,
             validate: [true, false],
             setter: ->(value) do
               set_value :has_horizontal_scroll, value do
                 with_handle do
                   User32.SetWindowLong(@hwnd, :STYLE, (User32.GetWindowLong(@hwnd, :STYLE) & ~User32::WindowStyle[:HSCROLL]) | (value ? User32::WindowStyle[:HSCROLL] : 0))
                   User32.InvalidateRect(@hwnd, nil, true)
                 end
               end
             end

    bindable :has_vertical_scroll,
             default:  false,
             validate: [true, false],
             setter: ->(value) do
               set_value :has_vertical_scroll, value do
                 with_handle do
                   User32.SetWindowLong(@hwnd, :STYLE, (User32.GetWindowLong(@hwnd, :STYLE) & ~User32::WindowStyle[:VSCROLL]) | (value ? User32::WindowStyle[:VSCROLL] : 0))
                   User32.InvalidateRect(@hwnd, nil, true)
                 end
               end
             end

    bindable :has_caption,
             default:  true,
             validate: [true, false],
             setter: ->(value) do
               set_value :has_caption, value do
                 with_handle do
                   User32.SetWindowLong(@hwnd, :STYLE, (User32.GetWindowLong(@hwnd, :STYLE) & ~User32::WindowStyle[:CAPTION]) | (value ? User32::WindowStyle[:CAPTION] : 0))
                   User32.InvalidateRect(@hwnd, nil, true)
                 end
               end
             end

    # WindowStyleExtended
    bindable :can_accept_files,
             default: false,
             validate: [true, false]

    bindable :focusable,
             default: true,
             validate: [true, false]

    bindable :is_pallete,
             default: false,
             validate: [true, false]

    bindable :is_toolbox,
             default: false,
             validate: [true, false]

    bindable :topmost,
             default: false,
             validate: [true, false]

    def_hooks :on_after_close,
              :on_before_close,
              :on_hide,
              :on_hotkey,
              :on_before_maximize,
              :on_after_maximize,
              :on_before_minimize,
              :on_after_minimize,
              :on_mousewheel,
              :on_mousemove,
              :on_before_restore,
              :on_after_restore,
              :on_got_focus,
              :on_lost_focus,
              :on_all_loaded,
              :on_loaded,
              :on_paint,
              :on_char,
              :on_key_release,
              :on_key_press,
              :on_create,
              :on_close,
              :on_vertical_scroll,
              :on_horizontal_scroll,
              :on_resize

    attr_reader :hwnd,
                :right,
                :bottom,
                :owner,
                :controls


    @win_id = 0
    @ignore_msg_list = Set[
        :NCCALCSIZE,
        :NCCREATE,
        :CREATE,
        :CLOSE,
        :DESTROY,
        :GETICON,
        :GETMINMAXINFO,
        :KEYDOWN,
        :KEYUP,
        :LBUTTONDOWN,
        :LBUTTONUP,
        :MOUSEMOVE,
        :MOUSEWHEEL,
        :MOVE,
        :MOVING,
        :NCDESTROY,
        :NCHITTEST,
        :NCMOUSELEAVE,
        :NCMOUSEMOVE,
        :NCUAHDRAWCAPTION,
        :PAINT,
        :NCPAINT,
        :RBUTTONDOWN,
        :RBUTTONUP,
        :SETCURSOR,
        :SETTEXT,
        :WINDOWPOSCHANGED,
        :WINDOWPOSCHANGING,
        :MOUSEMOVE,
        :ENTERIDLE,
        :TIMER,
        :PARENTNOTIFY,
        :NOTIFYFORMAT,
        :QUERYUISTATE,
        :SHOWWINDOW,
        :ACTIVATEAPP,
        :NCACTIVATE,
        :ACTIVATE,
        :IME_SETCONTEXT,
        :SETFOCUS,
        :SIZE,
        :ERASEBKGND,
        :PRINTCLIENT,
        :CTLCOLORBTN,
        :NOTIFY,
        :CTLCOLOREDIT,
        :CTLCOLORSTATIC,
        :NCLBUTTONDOWN,
        :CAPTURECHANGED,
    ]

    @opened = Set.new #Set<Window>

    def initialize(title:  '',
                   left:             User32::CW_USEDEFAULT,
                   top:              User32::CW_USEDEFAULT,
                   width:            User32::CW_USEDEFAULT,
                   height:           User32::CW_USEDEFAULT,
                   icon:             Icon.sample,
                   taskbar_icon:     nil,
                   application_icon: nil,
                   cursor:           Cursor.arrow,
                   menu:             nil,
                   background:       User32.GetSysColorBrush(User32::ColorType[:BTNFACE]))
      @mutex = Mutex.new
      @async = []
      @hotkey_id = 0

      self.title            = title
      self.left             = left
      self.top              = top
      self.width            = width
      self.height           = height
      self.icon             = icon
      self.taskbar_icon     = taskbar_icon     || self.icon
      self.application_icon = application_icon || self.icon
      self.cursor           = cursor

      yield self if block_given?
      @hinstance = DLL.module_handle

      # %i'
      #   top
      #   left
      #   height
      #   width
      # '.each do |attribute|
      #   on_changed attribute, method("#{attribute}_changed")
      # end

      @controls = Set.new

      icex = Comctl32::INITCOMMONCONTROLSEX.new.tap do |icc|
        icc.dwICC = Comctl32::InitCommonControls[:STANDARD_CLASSES]
        icc.dwSize = icc.size
      end
      Comctl32.InitCommonControlsEx(icex)

      ac = Kernel32::ACTCTX.new.tap do |ac|
        ac.lpSource = FFI::MemoryPointer.from_string(File.expand_path('winffi.manifest', __dir__).gsub('/', '\\').to_w)
      end

      Kernel32.ActivateActCtx(@ac = Kernel32.CreateActCtx(ac), @cookie = FFI::MemoryPointer.new(:ulong))

      id = self.class.instance_eval { @win_id += 1 }

      @wc = User32::WNDCLASSEX.new("WinFFI:#{id}").tap do |wc|
        wc.lpfnWndProc   = method(:window_proc)
        wc.cbWndExtra    = FFI::Type::Builtin::POINTER.size
        wc.hInstance     = @hinstance

        wc.hIcon         = self.taskbar_icon.hicon
        wc.hIconSm       = self.application_icon.hicon
        wc.hCursor       = self.cursor.hcursor
        wc.hbrBackground = background # TODO bindable attr
        wc.style         = create_window_class_style
      end

      @hwnd = User32.CreateWindowEx(
          create_window_style_extended, #WindowStyleExEnum
          FFI::Pointer.new(@wc.atom),
          self.title,
          create_window_style, #DWORD
          self.left,           #int x
          self.top,            #int y
          self.width,          #int width
          self.height,         #int height
          nil, #HWND
          menu&.hmenu, #HMENU
          @hinstance, #HINSTANCE
          nil
      ) #LPVOID

      @hwnd ? LOGGER.info("hwnd #{@hwnd} created") : error('Window creation failed')

      check_error

      # User32::NONCLIENTMETRICS.new { |ncm|
      #   ncm.cbSize = ncm.size
      #
      #   User32::SystemParametersInfo(:GETNONCLIENTMETRICS, ncm.size, ncm, 0);
      #   @hfont = CreateFontIndirect(ncm.lfMenuFont)
      # }

      r = RECT.new
      User32.GetWindowRect(@hwnd, r)
      User32.ClipCursor(r)

      %w'
        top
        left
        height
        width
      '.each do |dimension|
        self.send("#{dimension}=", r.send(dimension))
      end

      # LOGGER.debug('Calling window on create...')
      call_hooks :on_create
      # LOGGER.debug('Called window on_create')

      # rescue Exception => e
      #   error(e.message) if @hwnd
      #   raise e
    end

    def self.active_window
      @created[User32.GetActiveWindow]
    end

    %w'
      maximize
      minimize
      restore
    '.each do |state|
      define_method state, ->() do
        self.state = "#{state}d".to_sym
      end
    end

    def add_control(control, &block)
      @controls.add(control)
    end

    def bring_to_top
      with_handle { User32.SetWindowPos(@hwnd, FFI::Pointer.new(0), 0, 0, 0, 0, User32::SetWindowPosFlag[:NOSIZE] | User32::SetWindowPosFlag[:NOMOVE] | User32::SetWindowPosFlag[:FRAMECHANGED] ) }
    end

    def bring_to_bottom
      with_handle { User32.SetWindowPos(@hwnd, FFI::Pointer.new(1), 0, 0, 0, 0, User32::SetWindowPosFlag[:NOSIZE] | User32::SetWindowPosFlag[:NOMOVE] | User32::SetWindowPosFlag[:FRAMECHANGED]) }
    end

    def client_to_screen(position)
      position = case position
        when Array
          POINT.new.tap { |point| point.x = position[0] ; point.y = position[1]}
        when POINT then position
      end
      with_handle { User32.ClientToScreen(@hwnd, position) }
    end

    def move_to_topmost
      with_handle do
        User32.SetWindowPos(
            @hwnd, FFI::Pointer.new(-1), 0, 0, 0, 0,
            User32::SetWindowPosFlag[:NOSIZE] | User32::SetWindowPosFlag[:NOMOVE] | User32::SetWindowPosFlag[:FRAMECHANGED])
      end
    end

    def flash(invert)
      with_handle { User32.FlashWindow(@hwnd, invert) }
    end

    # can_close

    def toggle_can_close
      self.can_close = !self.can_close
    end

    # https://msdn.microsoft.com/en-us/library/windows/desktop/ff381396(v=vs.85).aspx
    def close
      with_handle { User32.DestroyWindow(@hwnd) }
      call_hooks :on_after_close
      User32.PostQuitMessage(0)
      @hwnd = nil
    end

    def enable
      self.enabled = true
    end

    def toggle_enabled
      self.enabled = !self.enabled
    end

    def disable
      self.enabled = false
    end

    def enabled?
      self.enabled
    end

    def message_box(text, *options, caption: self.title)
      with_handle { Dialog.message_box(text, *options, hwnd: @hwnd, caption: caption) }
    end

    def info_box(text, *options, caption: self.title)
      with_handle { Dialog.info_box(text, *options, hwnd: @hwnd, caption: caption) }
    end

    def error_box(text, *options, caption: self.title)
      with_handle { Dialog.error_box(text, *options, hwnd: @hwnd, caption: caption) }
    end

    def warning_box(text, *options, caption: self.title)
      with_handle { Dialog.warning_box(text, *options, hwnd: @hwnd, caption: caption) }
    end

    def question_box(text, *options, caption: self.title)
      with_handle { Dialog.question_box(text, *options, hwnd: @hwnd, caption: caption) }
    end

    def show(owner = nil)
      check_error
      return if visible

      opened = self.class.instance_variable_get(:@opened)

      if owner
        @dialog = ((owner.is_a?(Window) && owner) || self.owner || self.class.active_window ||
            opened.each_with_index.select { |_, i| i == x.length - 1 }.first[0])
        @disabled = opened.select { |w| w != self && w.enabled }
        @disabled.each { |w| w.enabled = false }
      end

      opened << self

      User32.ShowWindow(@hwnd, create_show_style)
      User32.BringWindowToTop(@hwnd)
      set_value :visible, true
      post_load_message unless @loaded
      User32.UpdateWindow(@hwnd)

      message_loop if @dialog || opened.count == 1
    end

    def hide
      return unless visible
      self.class.instance_eval { @opened }.delete self
      with_handle { User32.ShowWindow(@hwnd, :HIDE) }
      set_value :visible, false
      call_hooks :on_hide
      nil
    end

    def visible=(value)
      set_value(:visible, value) { value ? self.show : self.hide }
    end

    def visible?
      with_handle { User32.IsWindowVisible(@hwnd) }
    end

    def rect
      Rect.new(left, top, width, height)
    end

    def system_menu
      @system_menu ||= Menu.system_menu(self)
    end

    def run_async(&block)
      return unless block
      @mutex.synchronize { @async << block }
      send_message :NULL, 0, 0
    end

    def register_hotkey(key, *modifiers)
      key = User32::VirtualKeyCode[key]
      modifiers = modifiers.map { |m| User32::KeyboardModifier[m] }.reduce(0, &:|)
      User32.RegisterHotKey(@hwnd, @hotkey_id , modifiers, key)
      @hotkey_id += 1
    end

    def unregister_hotkey(id)
      with_handle { User32.UnregisterHotKey(@hwnd, id) }
    end

    def with_dc
      return unless block_given?
      hdc = DeviceContext.new(User32.GetDC(@hwnd))
      yield(hdc)
      User32.ReleaseDC(@hwnd, hdc.hdc)
    end

    def paint
      return unless block_given?
      with_handle {
        ps = PAINTSTRUCT.new
        hdc = DeviceContext.new(User32.BeginPaint(@hwnd, ps))
        yield(hdc)
        User32.EndPaint(@hwnd, ps)
      }
    end

    def set_scroll_range(min, max, page, direction: :vertical)
      direction = case direction
        when :vertical then :VERT
        when :horizonatl then :HORZ
      end
      si = User32::SCROLLINFO.new
      si.fMask = User32::ScrollbarInfoFlag[:RANGE] | User32::ScrollbarInfoFlag[:PAGE]
      si.nMin = min
      si.nMax = max
      si.nPage = page
      User32.SetScrollInfo(@hwnd, direction, si, true)
      User32.InvalidateRect(@hwnd, nil, true)
    end

    def set_scroll_pos(pos, direction: :vertical)
      si = User32::SCROLLINFO.new
      direction = case direction
        when :vertical then :VERT
        when :horizonatl then :HORZ
      end
      si.fMask = :POS
      si.nPos = pos
      User32.SetScrollInfo(@hwnd, direction, si, true)
      User32.InvalidateRect(@hwnd, nil, true)
    end

    def get_scroll_pos(direction: :vertical)
      si = User32::SCROLLINFO.new
      direction = case direction
        when :vertical then :VERT
        when :horizonatl then :HORZ
      end
      si.fMask = :POS
      User32.GetScrollInfo(@hwnd, direction, si)
      si.nPos
    end

    alias_method :exit,   :close
    alias_method :quit,   :close
    alias_method :handle, :hwnd

    private
    def detach(control)
      @controls.delete(control)
    end

    def check_error
      return unless @error
      LOGGER.error "#{@error.class}: #{@error}"
      LOGGER.error @error.backtrace
      error_box(@error.backtrace, caption: "#{@error.class}: #{@error}")
      Kernel.exit(false)
    end

    def create_window_class_style
      [
          # :OWNDC,
          :DBLCLKS,
          :VREDRAW,
          :HREDRAW,
          !can_close && :NOCLOSE,
          has_shadow && :DROPSHADOW
      ].select(&:itself).map { |v| User32::WindowClassStyle[v] }.reduce(0, &:|)
    end

    def create_window_style
      # removes falsey elements
      [
          can_minimize && !has_context_help && :MINIMIZEBOX,
          can_maximize && !has_context_help && :MAXIMIZEBOX,
          can_resize   && :SIZEBOX,
          has_horizontal_scroll && :HSCROLL,
          has_vertical_scroll   && :VSCROLL,
          visible && :VISIBLE,
          !enabled && :DISABLED,
          :OVERLAPPEDWINDOW,
          :CLIPCHILDREN,
          (can_minimize || can_maximize || can_close) && :SYSMENU,
      ].select(&:itself).map { |v| User32::WindowStyle[v] }.reduce(0, &:|)
    end

    def create_window_style_extended
      [
          can_accept_files && :ACCEPTFILES,
          has_context_help && :CONTEXTHELP,
          !focusable && :NOACTIVATE,
          is_pallete && :PALETTEWINDOW,
          is_toolbox && :TOOLWINDOW,
          topmost && :TOPMOST,
          :COMPOSITED, #double buffering
          :APPWINDOW,
          # :TRANSPARENT # DONT USE NO MATTER WHAT
      ].select(&:itself).map { |v| User32::WindowStyleExtended[v] }.reduce(0, &:|)
    end

    def create_show_style
      case self.state
        when :minimized
          :SHOWMINIMIZED
        when :maximized
          :SHOWMAXIMIZED
        else
          :SHOWNORMAL
      end
    end

    def error(error)
      LOGGER.error(error)
      nil
    end

    def window_proc(hwnd, msg, wparam, lparam)
      msg_name = User32::WindowMessage[msg].to_s
      if msg_name.empty?
        msg_name = AppWM[msg].to_s
      end

      name = msg_name.downcase
      begin
        handled = nil
        unless msg_name.empty?
          handled = call_handlers(name, hwnd: hwnd, wparam: wparam, lparam: lparam)

          if !handled.is_a?(Integer) && respond_to?("wm_#{name}", true)
            handled = send("wm_#{name}", OpenStruct.new(hwnd: hwnd, wparam: wparam, lparam: lparam))
          end
        end

        puts_msg(msg, hwnd, wparam, lparam)
        unless handled.is_a?(Integer)
          handled = User32.DefWindowProc(hwnd, msg, wparam, lparam)
        end

        handled
      rescue Exception => e
        # Have to explicitly catch all errors: if an error occurs, the stack will not be helpful,
        # since this method is called from native code.
        error(e)
        error_box(e.message)
        @error ||= e
        0
      end
    end

    def puts_msg(msg, hwnd, wparam = nil, lparam = nil)
      msg_id, msg_name = msg_pair(msg)
      return if ignore_msg_list.member?(msg_name.to_sym)

      msg_name = msg_id.to_s if msg_name.empty?
      s = "\t[#{'%#10x' % hwnd.to_i}] #{msg_name.ljust(25)}"
      s = "#{s} (#{'%#6x' % msg_id})"
      s << ' -> ' unless wparam.nil? && lparam.nil?
      {wparam: wparam, lparam: lparam}.each do |type, param|
        next if param.nil?
        s << " #{type}: [#{param.to_s}#{" (#{'%#x' % param})" if param.is_a?(Integer)}]"
      end
      LOGGER.info s
      nil
    end

    def ignore_msg_list
      self.class.instance_variable_get(:@ignore_msg_list)
    end

    def msg_pair(msg)
      if msg.is_a?(Integer)

        [msg, User32::WindowMessage[msg].to_s]
      else
        m = msg.to_sym

        [User32::WindowMessage[m].to_i, msg.to_s]
      end
    end

    def message_loop
      LOGGER.info "#{'%#x' % @hwnd.to_i} started a message loop"
      msg = User32::MSG.new

      while User32.GetMessage(msg, nil, 0, 0) > 0
        msg_id = User32::WindowMessage[msg.message] || msg.message

        # LOGGER.debug "Got message        #{msg_id}" unless ignore_msg_list.member?(msg_id)
        User32.TranslateMessage(msg)
        # LOGGER.debug "Translated message #{msg_id}" unless ignore_msg_list.member?(msg_id)

        User32.DispatchMessage(msg)
        # LOGGER.debug "Dispatched message #{msg_id}" unless ignore_msg_list.member?(msg_id)

        check_error
      end
    end

    def post_load_message
      User32.PostMessage(@hwnd, AppWM[:LOAD], 0, 0)
    end

    def wm_load(params)
      puts_msg :LOAD, params.hwnd

      # LOGGER.debug 'Calling window on_loaded hooks'
      call_hooks :on_loaded
      # LOGGER.debug 'Finished calling window on_loaded hooks'

      LOGGER.debug 'Calling controls on_loaded hooks'
      @controls.each do |control|
        # LOGGER.debug "Calling #{control} on_loaded hooks"
        control.send :call_hooks, :on_loaded
        # LOGGER.debug "Finished calling #{control} on_loaded hooks"
      end
      # LOGGER.debug 'Finished calling controls on_loaded hooks'

      # LOGGER.debug 'Calling window on_all_loaded hooks'
      call_hooks :on_all_loaded
      # LOGGER.debug 'Finished calling window on_loaded hooks'
      @loaded = true
      0
    end

    def moved(name, value)
      # LOGGER.debug "moved(#{name}, #{value.inspect})"
      r = rect
      r[name] = value
      if r.to_a.member?(nil)
        set_value name, value
      else
        User32.InvalidateRect(@hwnd, nil, true)
        User32.MoveWindow(@hwnd, r.left, r.top, r.width, r.height, true)
      end
    end

    def resize
      User32.InvalidateRect(@hwnd, nil, true)

      r = RECT.new
      User32.GetClientRect(@hwnd, r)
      r = Rect.new(r.left, r.top, r.width, r.height)

      set_value :client_rect, r
      call_hooks :on_resize, rect: r

      # LOGGER.debug "resizing(width = #{r.width}, height = #{r.height})"
    end

    def with_handle(&block)
      @hwnd ? block.call : on_loaded { block.call }
    end

    def send_message(message, wparam, lparam)
      with_handle { User32.SendMessage(@hwnd, User32::WindowMessage[message], wparam, lparam) }
    rescue Exception => e
      # LOGGER.debug "message=#{message},  wparam=#{wparam}, lparam=#{lparam}"
      raise e
    end

    def update_window
      User32.UpdateWindow(@hwnd)
    end

    AppWM = User32.enum :app_wm, {
        LOAD: 1
    }.flat_map { |k, v| [k, User32::WM_APP + v] }

  end
end
