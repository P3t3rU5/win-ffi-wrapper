require 'thread'
require 'ducktape'
require 'ducktape/bindable'

require 'win-ffi/user32/enum/window/control/button/button_style'
require 'win-ffi/user32/enum/window/message/window_message'

require 'win-ffi/user32/function/interaction/keyboard'
require 'win-ffi/user32/function/window/window'

using WinFFI::StringUtils
using WinFFI::BooleanUtils

module WinFFIWrapper
  module Control
    include Ducktape::Bindable, Ducktape::Hookable, WinFFI, WinFFI::User32

    @id = 0
    @id_mutex = Mutex.new
    def self.next_id
      @id_mutex.synchronize { @id += 1 }
    end

    @controls_mutex = Mutex.new
    @controls = {}
    def self.finalize_proc(control_id)
      proc do
        @controls_mutex.synchronize do
          @controls.delete(control_id)
        end
      end
    end

    def self.get_control(control_id)
      @controls_mutex.synchronize do
        object_id = @controls[control_id]
        ObjectSpace._id2ref(object_id) if object_id
      end
    end

    def self.list_controls
      @controls_mutex.synchronize do
        @controls
      end
    end

    def self.add_control(control)
      @controls_mutex.synchronize do
        control_id = control.id
        @controls[control_id] = control.object_id
        ObjectSpace.define_finalizer(control, Control.finalize_proc(control_id))
      end
    end

    bindable :text,
             default: '',
             validate: String,
             coerce: ->(_, value) { value.to_w },
             getter: (->() do
               text_size = User32.GetWindowTextLength(@handle) + 1
               text = ''
               FFI::MemoryPointer.new(:ushort, text_size) do |value|
                 User32.GetWindowText(@handle, value, text_size)
                 text = value.read_array_of_uint16(text_size - 1).pack('U*')
               end
               text
             end),
             setter: ->(value) do
               set_value :text, value do
                 User32.SetWindowText(@handle, value.to_w)
               end
             end

    bindable :visible,
             default: true,
             validate: [true, false],
             setter: ->(value) do
               set_value :visible, value do
                 User32.ShowWindow(@handle, value ? :SHOW : :HIDE)
               end
             end

    bindable :enabled,
             default: true,
             validate: [true, false],
             setter: ->(value) do
               set_value :enabled, value do
                 User32.EnableWindow(@handle, value)
                 call_hooks value ? :on_enable : :on_disable
               end
             end

    bindable :focused,
             default: false,
             validate: [true, false],
             setter: ->(value) do
               set_value :enabled, value do
                 if value
                   window.focused_control = self
                   call_hooks :on_got_focus
                 else
                   User32.SetFocus(nil)
                   call_hooks :on_lost_focus
                 end
               end
             end

    bindable :focusable,
             default: true,
             validate: [true, false]

    bindable :left,
             default: 0,
             validate: Integer

    bindable :top,
             default: 0,
             validate: Integer

    bindable :width,
             default: 200,
             validate: Integer

    bindable :height,
             default: 20,
             validate: Integer

    bindable :alignment,
             default: :center,
             validate: [:left, :center, :right]

    bindable :vertical_alignment,
             default: :center,
             validate: [:top, :center, :bottom]

    bindable :can_resize,
             default: false,
             validate: [true, false]

    bindable :has_horizontal_scroll,
             default:  false,
             validate: [true, false]

    bindable :has_vertical_scroll,
             default:  false,
             validate: [true, false]

    bindable :edge,
             default: :window,
             validate: [:window, :client, :static]

    bindable :font,
             default: Font.new('SegoeUI', 16),
             validate: Font,
             setter: ->(value) do
               set_value :font, value do
                 send_window_message(:SETFONT, self.font.handle.address, true.to_c)
               end
             end


    def_hooks :on_create,
              :on_click,
              :on_double_click,
              :on_got_focus,
              :on_lost_focus,
              :on_loaded,
              :on_enable,
              :on_disable

    attr_reader :window, :id, :handle

    def initialize(window, type)
      @id = next_id
      @window = window
      yield(self) if block_given?
      Control.add_control(self)

      on_create { send_window_message(:SETFONT, self.font.handle.address, true.to_c) }

      @handle = User32.CreateWindowEx(
          create_window_style_extended,
          type.to_w,             # Predefined class; Unicode assumed
          text.to_w,             # control text
          create_window_style,   # Styles
          left,                  # x position
          top,                   # y position
          width,                 # control width
          height,                # control height
          window.hwnd,           # Parent window
          FFI::Pointer.new(@id), # No menu.
          nil,
          nil)

      LOGGER.info("created #{self.class} #@id")

      call_hooks :on_create
    end

    def click
      call_hooks :on_click
    end

    def double_click
      call_hooks :on_double_click
    end

    def disable
      self.enabled = false
    end

    def enable
      self.enabled = true
    end

    def toggle_enabled
      self.enabled = !self.enabled
    end

    def show
      self.visible = true
    end

    def hide
      self.visible = false
    end

    def toggle_visibility
      self.visible = !self.visible
    end

    def to_s
      "#{self.class.name} #{@id}"
    end

    def command(param)
      # self.class
    end

    private
    def next_id
      Control.next_id
    end

    def create_window_style
      style = [
          can_resize            && :SIZEBOX,
          has_horizontal_scroll && :HSCROLL,
          has_vertical_scroll   && :VSCROLL,
          visible               && :VISIBLE,
          !enabled              && :DISABLED,
          focusable             && :TABSTOP,
          :CHILD,
          :CLIPCHILDREN,
      # :BORDER
      ].select { |flag| flag } # removes falsey elements
      style.map { |v| User32::WindowStyle[v] }.reduce(0, &:|)
    end

    def create_window_style_extended
      style = [
          (self.edge.to_s + 'edge').upcase.to_sym
      ].select { |flag| flag } # removes falsey elements
      style.map { |v| User32::WindowStyleExtended[v] }.reduce(0, &:|) # | button_style.map { |v| User32::ButtonStyle[v] }.reduce(0, &:|)
    end

    def detach
      @window.send(:detach, self)
    end

    def set_focus
      last_focused = window.focused_control
      last_focused.send(:kill_focus) if last_focused

      set_value :focused, true
    end

    def kill_focus
      set_value :focused, false
    end

    def clicked
      call_hooks :on_click
    end

    def double_clicked
      call_hooks :on_double_click
    end

    def send_message(message, wparam = 0, lparam = 0)
      if @handle
        User32.SendMessage(@handle, message, wparam, lparam) if @handle
      else
        on_loaded { send_message(message, wparam, lparam) }
      end
    end

    def send_window_message(message, wparam = 0, lparam = 0)
      if @handle
        User32.SendMessage(@handle, WindowMessage[message], wparam, lparam) if @handle
      else
        on_loaded do
          send_window_message(message, wparam, lparam)
        end
      end
    end

    alias_method :visible?,   :visible
    alias_method :enabled?,   :enabled
    alias_method :focused?,   :focused
    alias_method :focusable?, :focusable

    alias_method :can_resize?, :can_resize

    alias_method :has_horizontal_scroll?, :has_horizontal_scroll
    alias_method :has_vertical_scroll?, :has_vertical_scroll

  end
end