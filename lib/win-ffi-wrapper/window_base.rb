using WinFFI::StringUtils

require 'win-ffi-wrapper/dll'

module WinFFIWrapper
  module Window
    def self.init(title:  '',
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

      taskbar_icon ||= icon
      application_icon ||= icon
      self.style = style

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

  end
end