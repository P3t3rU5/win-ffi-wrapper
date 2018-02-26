require 'win-ffi/gdi32/function/brush'

module WinFFIWrapper
  class Brush
    class << self
      def indirect(style, color, hatch)
        new(hbrush: CreateBrushIndirect(
                        LOGBRUSH.new.tap do |lg|
                          lg.lbStyle = style
                          lg.lbColor = color
                          lg.lbHatch = hatch
                        end))
      end

      def solid_color(color)
        new(hbrush: CreateSolidBrush(color))
      end

      def hatch(style, color)
        new(hbrush: CreateSolidBrush(style.upcase, color))
      end
    end

    attr_reader :hbrush

    def initialize(hbrush: nil)
      @hbrush = hbrush
    end

    def to_native
      @hbrush
    end
  end
end