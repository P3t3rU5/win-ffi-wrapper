require 'thread'

using WinFFIWrapper::StringUtils

module WinFFIWrapper
  module Control
    include Ducktape::Bindable, Ducktape::Hookable

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
                 User32.SetWindowTextW(@handle, value.to_w)
               end
             end

    bindable :visible,
             default: true,
             validate: [true, false],
             setter: ->(value) do
               set_value :visible, value do
                 value ? User32.ShowWindow(@handle, :SHOW) : User32.ShowWindow(@handle, :HIDE)
               end
             end

    bindable :enabled,
             default: true,
             validate: [true, false],
             setter: ->(value) do
               set_value :enabled, value do
                 User32::EnableWindow(@handle, value)
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

    def_hooks :on_click, :on_got_focus, :on_lost_focus

    attr_reader :window, :id, :handle

    def initialize(window, type)
      @id = next_id
      @window = window
      yield(self) if block_given?
      Control.add_control(self)
      on_click do
        puts "clicked #{self}"
      end
      @handle = User32.CreateWindowExW(
          create_style_ex,
          type.to_w,             # Predefined class; Unicode assumed
          text.to_w,             # control text
          create_style,          # Styles
          left,                  # x position
          top,                   # y position
          width,                 # control width
          height,                # control height
          window.hwnd,           # Parent window
          FFI::Pointer.new(@id), # No menu.
          nil,
          nil)
    end

    def disable
      self.enabled = false
    end

    def enable
      self.enabled = true
    end

    def show
      self.visible = true
    end

    def hide
      self.visible = false
    end

    def to_s
      "#{self.class.name} #{@id}"
    end

    private
    def next_id
      Control.next_id
    end

    def create_style
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

      button_style = [
          alignment.upcase,
          vertical_alignment == :center ? :VCENTER : vertical_alignment.upcase
      ].select { |flag| flag } # removes falsey elements

      style.map { |v| User32::WindowStyle[v] }.reduce(0, &:|) | button_style.map { |v| User32::ButtonControlStyle[v] }.reduce(0, &:|)
    end

    def create_style_ex; User32::WindowStyleEx[:WINDOWEDGE] | 0 end

    def detach
      @window.send(:detach, self)
    end

    def setfocus
      set_value :focused, true
      call_hooks :on_got_focus
    end

    def killfocus
      set_value :focused, false
      call_hooks :on_lost_focus
    end
  end
end