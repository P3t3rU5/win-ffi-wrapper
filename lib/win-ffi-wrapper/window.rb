require 'win-ffi-wrapper/util'
using WinFFIWrapper::StringUtils

require 'pathname'
require 'facets/ostruct'
require 'set'
require 'ducktape'

require 'win-ffi/enums/user32/window/window_messages'
require 'win-ffi/enums/comctl32/init_common_controls'
require 'win-ffi/enums/color_types'

require 'win-ffi/functions/comctl32/control'
require 'win-ffi/functions/kernel32/activation'
require 'win-ffi/functions/user32/brush'
require 'win-ffi/functions/user32/window/window'
require 'win-ffi/functions/user32/window/message'
require 'win-ffi/functions/user32/painting_drawing'

require 'win-ffi/structs/comctl32/init_common_controls_ex'
require 'win-ffi/structs/kernel32/actctx'
require 'win-ffi/structs/user32/window/wndclassex'
require 'win-ffi/structs/user32/window/non_client_metrics'

require 'win-ffi-wrapper/window/control/style'
require 'win-ffi-wrapper/resource'
require 'win-ffi-wrapper/dll'
require 'win-ffi-wrapper/dialog'
require 'win-ffi-wrapper/window/control/base_control'

(Pathname[__dir__] / 'window/message').visit { |f| require f }

module WinFFIWrapper
  class Window #< Control
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
                 User32.SetWindowTextW(@hwnd, v) if @hwnd
               end
             end)

    bindable :enabled,
             default: true,
             validate: [true, false],
             setter: (->(enabled) do
               set_value(:title, value) do |v|
                 User32.EnableWindow(@hwnd, v) if @hwnd
               end
             end)

    bindable :visible,
             access: :readonly,
             default: false,
             validate: [true, false]

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
             validate: Integer

    bindable :width,
             default: User32::CW_USEDEFAULT,
             validate: Integer

    bindable :left,
             default: User32::CW_USEDEFAULT,
             validate: Integer

    bindable :top,
             default: User32::CW_USEDEFAULT,
             validate: Integer

    bindable :max_height,
             validate: [Integer, nil] #TODO not working yet

    bindable :min_height,
             validate: [Integer, nil] #TODO not working yet

    bindable :max_width,
             validate: [Integer, nil] #TODO not working yet

    bindable :min_width,
             validate: [Integer, nil] #TODO not working yet

    bindable :focused_control,
             access: :readonly,
             default: nil,
             validate: [Control, nil]

    bindable :client_rect,
             access: :readonly,
             validate: Rect,
             default: ->() { Rect.new },
             getter: ->() { get_value(:client_rect).dup }

    def_hooks :on_after_close,
              :on_before_close,
              :on_hide,
              :on_hotkey,
              :on_maximize,
              :on_minimize,
              :on_mousewheel,
              :on_mousemove,
              :on_restore,
              :on_got_focus,
              :on_lost_focus,
              :on_loaded,
              :on_paint,
              :on_char,
              :on_key_release,
              :on_key_press,
              :on_create

    attr_reader :hwnd,
                :center_mode,
                :right,
                :bottom,
                :owner


    @win_id = 0
    @ignore_msg_list = Set[
        :WM_NCCALCSIZE,
        :WM_CREATE,
        :WM_CLOSE,
        :WM_DESTROY,
        :WM_GETICON,
        :WM_GETMINMAXINFO,
        :WM_KEYDOWN,
        :WM_KEYUP,
        :WM_LBUTTONDOWN,
        :WM_LBUTTONUP,
        :WM_MOUSEMOVE,
        :WM_MOUSEWHEEL,
        :WM_MOVE,
        :WM_MOVING,
        :WM_NCDESTROY,
        :WM_NCHITTEST,
        :WM_NCMOUSELEAVE,
        :WM_NCMOUSEMOVE,
        :WM_NCUAHDRAWCAPTION,
        :WM_PAINT,
        :WM_RBUTTONDOWN,
        :WM_RBUTTONUP,
        :WM_SETCURSOR,
        :WM_SETTEXT,
        :WM_WINDOWPOSCHANGED,
        :WM_WINDOWPOSCHANGING,
    ]

    @opened  = Set.new #Set<Window>

    def initialize(title:  '',
                   left:   User32::CW_USEDEFAULT,
                   top:    User32::CW_USEDEFAULT,
                   width:  User32::CW_USEDEFAULT,
                   height: User32::CW_USEDEFAULT,
                   icon:   Icon.sample,
                   taskbar_icon:     nil,
                   application_icon: nil,
                   cursor:  Cursor.normal,
                   style:       Style.new)
      hinstance = DLL.module_handle

      %i'
        top
        left
        height
        width
      '.each do |attribute|
        on_changed attribute, method("#{attribute}_changed")
      end
      @controls = Set.new
      taskbar_icon ||= icon
      application_icon ||= icon
      self.style = style
      icex = Comctl32::INITCOMMONCONTROLSEX.new.tap do |icc|
        icc.dwICC = Comctl32::InitCommonControls[:STANDARD_CLASSES]
      end
      Comctl32.InitCommonControlsEx(icex)

      ac = Kernel32::ACTCTX.new.tap do |ac|
        ac.lpSource = FFI::MemoryPointer.from_string(File.expand_path('winffi.manifest', __dir__).gsub('/', '\\').to_w)
      end
      Kernel32.ActivateActCtx(@ac = Kernel32.CreateActCtxW(ac),  @cookie = FFI::MemoryPointer.new(:ulong))

      id = self.class.instance_eval { @win_id += 1 }
      @wc = User32::WNDCLASSEX.new("WinFFI:#{id}").tap do |wc|
        wc.lpfnWndProc   = method(:window_proc)
        wc.cbWndExtra    = FFI::Type::Builtin::POINTER.size
        wc.hInstance     = hinstance
        wc.hIcon         = taskbar_icon.handle
        wc.hIconSm       = application_icon.handle
        wc.hCursor       = cursor.hcursor
        wc.hbrBackground = User32.GetSysColorBrush(ColorTypes[:BTNFACE]) #TODO
        wc.style         = style.create_class_style
      end
      # this is line needs to be here because CreateWindowEx doesn't update the :title bindable
      self.title = title

      @hwnd = User32.CreateWindowExW(
          style.create_style_ex, #WindowStyleExEnum
          FFI::Pointer.new(@wc.atom),
          self.title,
          style.create_style, #DWORD
          left, #int x
          top, #int y
          width, #int width
          height, #int height
          nil, #HWND
          nil, #HMENU
          hinstance, #HINSTANCE
          nil
      ) #LPVOID

      Dialog.message_box('Window creation failed', :ICONERROR) unless @hwnd

      # User32::NONCLIENTMETRICS.new { |ncm|
      #   ncm.cbSize = ncm.size
      #
      #   User32::SystemParametersInfo(:GETNONCLIENTMETRICS, ncm.size, ncm, 0);
      #   @hfont = CreateFontIndirect(ncm.lfMenuFont)
      # }

      r = RECT.new
      User32.GetWindowRect(@hwnd, r)
      %w'
        top
        left
        height
        width
      '.each do |dimension|
        self.send("#{dimension}=", r.send(dimension))
      end

      yield self if block_given?
      call_hooks :on_create

    rescue Exception => e
      Dialog.message_box(e.message, :ICONERROR) if @hwnd
      raise e
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
        @style.state = "#{state}d".to_sym
        call_hooks "on_#{state}"
        nil
      end
    end

    def add_control(control, &block)
      @controls.add(control)
    end

    def bring_to_top
      User32.SetWindowPos(@hwnd, FFI::Pointer.new(0), 0, 0, 0, 0, User32::SetWindowPosFlags[:NOSIZE] | User32::SetWindowPosFlags[:NOMOVE] | User32::SetWindowPosFlags[:FRAMECHANGED] )
    end

    def bring_to_bottom
      User32.SetWindowPos(@hwnd, FFI::Pointer.new(1), 0, 0, 0, 0, User32::SetWindowPosFlags[:NOSIZE] | User32::SetWindowPosFlags[:NOMOVE] | User32::SetWindowPosFlags[:FRAMECHANGED])
    end

    def topmost
      User32.SetWindowPos(@hwnd, FFI::Pointer.new(-1), 0, 0, 0, 0, User32::SetWindowPosFlags[:NOSIZE] | User32::SetWindowPosFlags[:NOMOVE] | User32::SetWindowPosFlags[:FRAMECHANGED])
    end

    def flash(invert)
      User32.FlashWindow(@hwnd, invert)
    end

    def can_close=(value)
      @style.can_close = value
      c = value ? 0 : User32::WindowClassStyle[:NOCLOSE]
      User32.SetClassLongW(@hwnd, :STYLE, (User32.GetClassLongW(@hwnd, :STYLE) & ~User32::WindowClassStyle[:NOCLOSE]) | c)
    end

    def toggle_can_close
      self.can_close = !@style.can_close
    end

    # https://msdn.microsoft.com/en-us/library/windows/desktop/ff381396(v=vs.85).aspx
    def close
      User32.DestroyWindow(@hwnd)
      User32.PostQuitMessage(0)
    end

    def enabled=(v)
      @style.enabled = v
    end

    def enable

    end

    def toggle
      self.enabled = !@enabled
    end

    def disable

    end

    def message_box(text, *options, caption: nil)
      options = options.map { |o| o.is_a?(Symbol) ? User32::MessageBoxFlags[o] : o }.reduce(0, &:|)
      Dialog.message_box(text, options, hwnd: @hwnd, caption: caption)
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

      message_loop if @dialog || opened.count == 1
    end

    def hide
      return unless visible
      self.class.instance_eval { @opened }.delete self
      User32.ShowWindow(@hwnd, :HIDE)
      set_value :visible, false
      call_hooks :on_hide
      nil
    end

    def visible?
      User32.IsWindowVisible(@hwnd)
    end

    def application_icon=(v)
      User32.SendMessageW(@hwnd, User32::WindowMessages[:WM_SETICON], User32::Icon[:SMALL], v.hicon.address)
    end

    def taskbar_icon=(v)
      User32.SendMessageW(@hwnd, User32::WindowMessages[:WM_SETICON], User32::Icon[:BIG],   v.hicon.address)
    end

    def rect
      Rect.new(left, top, width, height)
    end

    def style=(v)
      # TODO unbind_style

      @style = v
      %i'
        state
      '.each do |attribute|
        @style.on_changed attribute, method("#{attribute}_changed")
      end
    end

    private
    def detach(control)
      @controls.delete(control)
    end

    # changed

    def title_changed(_, _, params)
      User32.SetWindowTextW(@hwnd, params[:value].to_w)
    end

    def state_changed(_, _, params)
      state = params[:value].to_s.chop.upcase.to_sym
      User32.ShowWindow(@hwnd, state)
      User32.InvalidateRect(@hwnd, nil, true)
      User32.UpdateWindow(@hwnd)
    end

    %w'
      height
      left
      top
      width
    '.each do |name|
      define_method "#{name}_changed", ->(_, _, params) do
        moved name, params[:value]
      end
    end

    def check_error
      return unless @error
      $stderr.puts "#{@error.class}: #{@error}", @error.backtrace
      exit(false)
    end

    def create_show_style
      case @state
      when :minimized
        :SHOWMINIMIZED
      when :maximized
        :SHOWMAXIMIZED
      else
        :SHOWNORMAL
      end
    end

    def window_proc(hwnd, msg, wparam, lparam)
      msg_name = User32::WindowMessages[msg].to_s
      if msg_name.empty?
        msg_name = AppWM[msg].to_s
      end

      name = msg_name.downcase
      begin
        handled = nil
        unless msg_name.empty?
          handled = call_handlers(name, hwnd: hwnd, wparam: wparam, lparam: lparam)

          if !handled.is_a?(Integer) && respond_to?(name, true)
            handled = send(name, OpenStruct.new(hwnd: hwnd, wparam: wparam, lparam: lparam))
          end
        end

        unless handled.is_a?(Integer)
          puts_msg(msg, hwnd, wparam, lparam)
          handled = User32.DefWindowProcW(hwnd, msg, wparam, lparam)
        end

        handled
      rescue Exception => e
        #Have to explicitly catch all errors: if an error occurs, the stack will not be helpful,
        #since this method is called from native code.
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
      puts s
    end

    def ignore_msg_list
      self.class.instance_variable_get(:@ignore_msg_list)
    end

    def msg_pair(msg)
      if msg.is_a?(Integer)
        [msg, User32::WindowMessages[msg].to_s]
      else
        m = msg.to_sym
        [User32::WindowMessages[m].to_i, msg.to_s]
      end
    end

    def message_loop
      puts "#{'%#x' % @hwnd.to_i} started a message loop"
      msg = User32::MSG.new
      while User32.GetMessageW(msg, nil, 0, 0) > 0
        #msg_id = User32::WindowMessages[msg.message] || msg.message
        #puts "Got message        #{msg_id}"
        User32.TranslateMessage(msg)
        #puts "Translated message #{msg_id}"
        User32.DispatchMessageW(msg)
        #puts "Dispatched message #{msg_id}"

        check_error
      end
    end

    def post_load_message
      User32.PostMessageW(@hwnd, AppWM[:WM_LOAD], 0, 0)
    end

    def wm_load(params)
      puts_msg :WM_LOAD, params.hwnd

      call_hooks :on_loaded
      @loaded = true
    end

    def moved(name, value)
      #puts "moved(#{name}, #{value.inspect})"
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

      #puts "resizing(width = #{r.width}, height = #{r.height})"
    end

    def update_window
      User32.UpdateWindow(@hwnd)
    end

    AppWM = User32.enum :app_wm,
                        {
                            WM_LOAD: 1
                        }.flat_map { |k, v| [k, User32::WindowMessages[:WM_APP] + v] }

  end
end
