module WinFFIWrapper
  class Window
    # wParam - The virtual-key code of the nonsystem key.
    def wm_keydown(params)
      key = User32::VirtualKeyFlags[params.wparam]
      puts "keydown #{key}"
      call_hooks(:on_key_press, key: key)
      case key
      when 'space' then Dialog.message_box(self.title, :ICONERROR, caption: ('1º'.to_w))
      end
      0
    end
    private :wm_keydown
  end
end
