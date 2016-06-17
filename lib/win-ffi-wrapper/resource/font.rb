using WinFFI::StringUtils
using WinFFI::BooleanUtils

require 'win-ffi/gdi32/function/text'

module WinFFIWrapper
  class Font

    FAMILIES = {}
    FONTS = {}

    def self.families
      FAMILIES
    end

    attr_reader :handle

    alias_method :hfont, :handle

    def initialize(font_family, height, weigth: :DONTCARE, italic: false, underline: false, strikeout: false,
                   charset: :ANSI, output_precision: :TT, clip_precision: :DEFAULT, quality: :CLEARTYPE_NATURAL_QUALITY,
                   family_pitch: :DEFAULT)
      @name = font_family
      @handle = Gdi32.CreateFont(
          height,                                       # nHeight
          0,                                            # nWidth
          0,                                            # nEscapement
          0,                                            # nOrientation
          Gdi32::FontWeight[weigth],                    # fnWeight
          italic.to_c,                                  # fdwItalic
          underline.to_c,                               # fdwUnderline
          strikeout.to_c,                               # fdwStrikeOut
          Gdi32::FontCharset[charset],                  # fdwCharSet
          Gdi32::FontOutputPrecision[output_precision], # fdwOutputPrecision
          Gdi32::FontClipPrecision[clip_precision],     # fdwClipPrecision
          Gdi32::FontQuality[quality],                  # fdwQuality
          Gdi32::FontFamilyPitch[family_pitch],         # fdwPitchAndFamily
          font_family
      )

      at_exit do
        WinFFIWrapper::LOGGER.debug "Deleting Font..."
        Gdi32.DeleteObject(@hfont)
        @hfont = 0
        WinFFIWrapper::LOGGER.debug "Font deleted"
      end
    end

    def self.list
      hdc = Screen.hdc

      WinFFI::Gdi32.EnumFontFamilies(hdc, nil, method(:enum_font_proc), 0)
      # WinFFI::Gdi32.EnumFontFamiliesEx(hdc, lf, method(:enum_font_proc), 0, 0)
    end

    def self.enum_font_proc(lplf, _, _, _)
      FAMILIES[lplf.family] = lplf
      1
    end

    alias_method :handle, :hfont

  end
end