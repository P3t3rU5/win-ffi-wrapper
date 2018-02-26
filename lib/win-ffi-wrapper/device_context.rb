using WinFFIWrapper::StringUtils

require 'win-ffi/user32/function/painting_drawing'

module WinFFIWrapper
  class DeviceContext
    attr_reader :hdc

    def initialize(hdc)
      @hdc = hdc
    end

    def draw_text(text, rect, *options)
      options = options.map { |o| o.is_a?(Symbol) ? User32::DrawTextFormatFlag[o] : o }.reduce(0, &:|)
      text = text.to_s.to_w
      User32.DrawText(@hdc, text, text.length, rect, options)
    end

    def text_out(text, x: 0, y: 0)
      text = text.to_s.to_w
      Gdi32.TextOut(@hdc, x, y, text, text.length)
    end

    def text_align(*options)
      options = options.map { |o| o.is_a?(Symbol) ? Gdi32::TextAlignFlag[o] : o }.reduce(0, &:|)
      Gdi32.SetTextAlign(@hdc, options)
    end

    def text_metrics
      Gdi32::TEXTMETRIC.new.tap do |tm|
        Gdi32.GetTextMetrics(@hdc, tm)
      end
    end

    def self.stock_object(object)
      Gdi32.GetStockObject(object)
    end
  end
end