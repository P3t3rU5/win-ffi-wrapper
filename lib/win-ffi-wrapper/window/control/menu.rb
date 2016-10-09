# require 'lib/win-ffi/user32/struct/window/menu_info'

require 'win-ffi/user32/enum/resource/menu/menu_flag'

require 'win-ffi/user32/function/resource/menu'

using WinFFIWrapper::StringUtils
module WinFFIWrapper
  class Window
    def add_menu_item(menu_item)
      add_control(menu_item)
    end

    def set_menu(menubar)
      User32.SetMenu(@hwnd, menubar.handle)
    end
  end

  class MenuItem
    include Control

    bindable :text,
             default: 'MenuItem',
             validate: String,
             coerce: ->(_, value) { value.to_w }

    attr_accessor :parent, :enabled, :checked

    def initialize(&block)
      @id = next_id
      @parent = nil
      yield(self) if block_given?
      Control.add_control(self)
    end

    def command(_)
      call_hooks :on_click
    end

    def root
      parent = @parent
      if parent
        while(parent)
          parent = @parent.parent
        end
      end
    end
  end

  class Menu < MenuItem

    bindable :text,
             default: 'Menu'.to_w,
             validate: String,
             coerce: ->(_, value) { value.to_w }

    def self.system_menu(window)
      new(window).instance_eval do
        self.handle = User32.GetSystemMenu(window.hwnd, false)
        self
      end
    end

    attr_reader :handle

    def initialize(window, &block)
      @window = window
      @handle = User32.CreateMenu
      super(&block)
    end

    def add_menu_item(menu_item)
      menu_item.parent = self
      @window.add_menu_item(menu_item)
      append_menu(menu_item.id, menu_item.text.to_w, :STRING)
    end

    def add_sub_menu(sub_menu)
      sub_menu.parent = self
      append_menu(sub_menu.handle.address, sub_menu.text.to_w, :STRING, :POPUP)
    end

    def add_separator
      append_menu(0, nil, :SEPARATOR);
    end

    protected
    attr_writer :handle

    private
    def append_menu(id, text, *flags)
      flags = flags.map { |o| o.is_a?(Symbol) ? User32::MenuFlag[o] : o }.reduce(0, &:|)
      User32.AppendMenu(@handle, flags, id, text.to_w)
    end
  end

  class SubMenu < Menu

    bindable :text,
             default: 'SubMenu'.to_w,
             validate: String,
             coerce: ->(_, value) { value.to_w }

    def initialize(window, &block)
      @window = window
      @handle = User32.CreatePopupMenu
      super(window, &block)
    end
  end

  class MenuBar < Menu
    def initialize(window, &block)
      super(window, &block)
    end

    def add_menu(menu)
      menu.parent = self
      append_menu(menu.handle.address, menu.text, :POPUP)
    end
  end

  class PopupMenu < Menu
    def initialize(w, &block)
      @window = window
      @handle = User32.CreatePopupMenu
      super(window, &block)
    end

    # point.x = LOWORD(lParam);
    # point.y = HIWORD(lParam);
    # hMenu = CreatePopupMenu();
    # ClientToScreen(hwnd, &point);

    # TrackPopupMenu(@handle, :RIGHTBUTTON, point.x, point.y, 0, w.hwnd, NULL);
    # DestroyMenu(@handle);


  end
end