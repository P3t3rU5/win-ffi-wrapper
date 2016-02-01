require 'thread'

require 'win-ffi/user32/function/window/window'
require 'win-ffi/user32/enum/window/style/button_style'
require 'win-ffi/user32/function/interaction/keyboard'

using WinFFIWrapper::StringUtils

module WinFFIWrapper
  module Control
    include Ducktape::Bindable, Ducktape::Hookable, WinFFI

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
               end
             end

    bindable :focused,
             access: :readonly,
             default: false,
             validate: [true, false]

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

    def_hooks :on_click, :on_doubleclick, :on_got_focus, :on_lost_focus, :on_loaded, :on_disable

    attr_reader :window, :id, :handle

    def initialize(window, type)
      @id = next_id
      @window = window
      yield(self) if block_given?
      Control.add_control(self)

      @handle = User32.CreateWindowEx(
          create_window_style_extended,          type.to_w,             # Predefined class; Unicode assumed
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
    end

    def click
      call_hooks :on_click
    end

    def double_click
      call_hooks :on_doubleclick
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
      window.focused_control = self
      set_value :focused, true
      call_hooks :on_got_focus
    end

    def disabled
      call_hooks :on_disable
    end

    def kill_focus
      set_value :focused, false
      call_hooks :on_lost_focus
    end

    def clicked
      call_hooks :on_click
    end

    def double_clicked
      call_hooks :on_doubleclick
    end
  end
end