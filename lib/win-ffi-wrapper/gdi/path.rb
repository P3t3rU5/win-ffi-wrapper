require 'win-ffi/gdi32/function/path'
require 'win-ffi/gdi32/function/line_curve'
require 'win-ffi/core/struct/point'

module WinFFIWrapper
  class Path
    def initialize(hdc)
      @hdc = hdc
      begin_path
      Gdi32.BeginPath(@hdc)
      if block_given?
        yield self
        end_path
      end
    end

    def move_to(x, y)
      return if @ended
      MoveToEx(@hdc, x, y, POINT.new)
    end

    def line_to(x, y)
      return if @ended
      LineTo(@hdc, x, y)
    end

    def abort
      Gdi32.AboerPath(@hdc)
    end

    def fill(brush)
      Gdi32.SelectObject(@hdc, brush)
      Gdi32.FillPath(@hdc)
    end

    def flatten
      end_path unless @ended
      Gdi32.FlattenPath(hdc)
    end

    def get
      n = Gdi32.GetPath(@hdc, nil, nil, 0)
      points = FFI::MemoryPointer.new(POINT, n)
      types = FFI::MemoryPointer.new(:uchar, n)
      Gdi32.GetPath(@hdc, points, types, n)
      points = n.times.map { |idx| POINT.new(points + idx * POINT.size) }
      types.read_array_of_uchar(n).map! { |type| PointType[type] }
      n.times.map { |i| [points[i], types[i]] }
    end

    def end_path
      Gdi32.EndPath(@hdc)
      @ended = true
    end

    def stroke(pen)
      end_path unless @ended
      Gdi32.SelectObject(@hdc, pen)
      Gdi32.StrokePath(@hdc)
    end

    def stroke_and_fill(pen, brush)
      end_path unless @ended
      Gdi32.SelectObject(@hdc, pen)
      Gdi32.SelectObject(@hdc, brush)
      Gdi32.StrokeAndFillPath(@hdc)
    end

    def widen
      Gdi32.WidenPath(@hdc)
    end

    def to_region
      end_path unless @ended
      Gdi32.PathToRegion(@hdc)
    end

  end
end