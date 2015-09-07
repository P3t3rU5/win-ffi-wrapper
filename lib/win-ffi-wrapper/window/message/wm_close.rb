module WinFFIWrapper
  class Window
    def wm_close(params)
      puts_msg :WM_CLOSE, params.hwnd

      return 0 if call_handlers(:on_before_close)

      opened = self.class.instance_variable_get(:@opened)
      opened.delete self

      if @disabled
        @disabled.each { |w| w.enabled = true }
        remove_instance_variable :@disabled
      end

      User32.PostQuitMessage(0) if @dialog || opened.count == 0

      hide
      call_hooks :on_after_close
      0
    end
    private :wm_close
  end
end