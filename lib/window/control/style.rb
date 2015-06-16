module WinFFIWrapper
  class Window
    class Style
      include Ducktape::Bindable

      #:DISABLED flag is instead handled by Window#enabled attribute using EnableWindow
      #:MINIMIZED, :MAXIMIZED, :VISIBLE can't be used because of the way the message loop is implemented

      bindable :can_accept_files,
               default: false,
               validate: [true, false]

      bindable :can_close,
               default:  true,
               validate: [true, false]

      bindable :can_maximize,
               default:  true,
               validate: [true, false]

      bindable :can_minimize,
               default:  true,
               validate: [true, false]

      bindable :can_resize,
               default:  true,
               validate: [true, false]

      bindable :has_context_help,
               default: false,
               validate: [true, false]

      bindable :has_horizontal_scroll,
               default:  false,
               validate: [true, false]

      bindable :has_vertical_scroll,
               default:  false,
               validate: [true, false]

      bindable :has_shadow,
               default: false,
               validate: [true, false]

      bindable :is_pallete,
               default: false,
               validate: [true, false]

      bindable :is_toolbox,
               default: false,
               validate: [true, false]

      bindable :enabled,
               default: true,
               validate: [true, false]

      bindable :topmost,
               default: false,
               validate: [true, false]

      bindable :not_focusable,
               default: false,
               validate: [true, false]

      bindable :state,
               default:  :restored,
               validate: [:restored, :minimized, :maximized]

      def initialize
        yield self if block_given?
      end

      def create_style
        s = [
            can_minimize && !has_context_help && :MINIMIZEBOX,
            can_maximize && !has_context_help && :MAXIMIZEBOX,
            can_resize   && :SIZEBOX,
            has_horizontal_scroll && :HSCROLL,
            has_vertical_scroll   && :VSCROLL,
            # visible && :VISIBLE,
            !enabled && :DISABLED,
            :OVERLAPPEDWINDOW,
            # :CLIPCHILDREN,
            (can_minimize || can_maximize || can_close) && :SYSMENU
        ].select { |x| x } # removes falsey elements

        s.map { |v| User32::WindowStyle[v] }.reduce(0, &:|)
      end

      def create_style_ex
        s = [
            can_accept_files && :ACCEPTFILES,
            has_context_help && :CONTEXTHELP,
            not_focusable && :NOACTIVATE,
            is_pallete && :PALETTEWINDOW,
            is_toolbox && :TOOLWINDOW,
            topmost && :TOPMOST,
            # :COMPOSITED, #double buffering
            :APPWINDOW
        ].select { |x| x }
        s.map { |v| User32::WindowStyleEx[v] }.reduce(0, &:|)
      end

      def create_class_style
        s = [
            :OWNDC,
            :DBLCLKS,
            # :VREDRAW,
            # :HREDRAW,
            !can_close && :NOCLOSE,
            has_shadow && :DROPSHADOW
        ].select { |x| x }
        s.map { |v| User32::WindowClassStyle[v] }.reduce(0, &:|)
      end
    end
  end
end