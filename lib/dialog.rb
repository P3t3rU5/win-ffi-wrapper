using WinFFIWrapper::StringUtils

module WinFFIWrapper
  module Dialog
    def CreateDialog(hInstance, lpName, hParent, lpDialogFunc)
      User32::CreateDialogParam(hInstance, lpName, hParent, lpDialogFunc, 0)
    end

    def CreateDialogIndirect(hInst, lpTemp, hPar, lpDialFunc)
      User32::CreateDialogIndirectParam(hInst, lpTemp, hPar, lpDialFunc, 0)
    end

    def DialogBox(hInstance, lpTemp, hParent, lpDialogFunc)
      User32::DialogBoxParam(hInstance, lpTemp, hParent, lpDialogFunc, 0)
    end

    def DialogBoxIndirect(hInst, lpTemp, hParent, lpDialogFunc)
      User32::DialogBoxIndirectParam(hInst, lpTemp, hParent, lpDialogFunc, 0)
    end
    class << self
      def message_box(text, *options, hwnd: nil, caption: nil)
        options = options.map { |o| o.is_a?(Symbol) ? User32::MessageBoxFlags[o] : o }.reduce(0, &:|)
        User32.MessageBoxW(hwnd, text.to_w, caption.to_w, options)
      end
    end
  end
end
