module WinFFIWrapper
  class Window
    private def wm_paint(params)
      call_hooks(:on_paint) || 1
    end
  end
end