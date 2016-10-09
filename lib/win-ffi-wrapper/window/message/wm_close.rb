module WinFFIWrapper
  class Window
    private def wm_close(params)
      puts_msg :CLOSE, params.hwnd

      return 0 if call_handlers(:on_before_close)

      opened = self.class.instance_variable_get(:@opened)
      opened.delete self

      if @disabled
        @disabled.each { |w| w.enabled = true }
        remove_instance_variable :@disabled
      end
      User32.DestroyWindow(@hwnd)
      call_hooks :on_after_close
      User32.PostQuitMessage(0) if @dialog || opened.count == 0
      hide
      0
    end
  end
end