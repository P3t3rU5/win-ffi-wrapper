require 'win-ffi/user32/enum/image'
require 'win-ffi/user32/function/resource'

require 'win-ffi-wrapper/util'

module WinFFIWrapper
  using StringUtils

  class Resource

    include WinFFI
    attr_reader :handle, :name

    def initialize(resource_type, filepath, name, hinstance = nil)
      @name = name
      filepath, from_file = filepath.is_a?(String) ?
          [filepath.to_w, LoadResourceFlags[:LOADFROMFILE]] :
          [filepath, 0]
      @handle = WinFFI::User32.LoadImage(
          hinstance,            # hInstance must be NULL when loading from a file
          filepath,             # the icon file name
          resource_type,        # specifies that the file is an icon
          0,                    # width of the image (we'll specify default later on)
          0,                    # height of the image
          from_file         |   # we want to load a file (as opposed to a resource)
              LoadResourceFlags[:DEFAULTSIZE]  |   # default metrics based on the type (IMAGE_ICON, 32x32)
              LoadResourceFlags[:SHARED]
      )
    end
  end

  class Icon < Resource

    alias_method :hicon, :handle

    def initialize(filepath, hinstance = nil)
      # can't use FFI::MemoryPointer because it's freed after initialization
      # it also makes sense to use FFI::Pointer because the OIC flag isn't allocated memory
      filepath, name = filepath.is_a?(String) ?
          [filepath.to_w, filepath.split('\\').last.split('.').first] :
          [FFI::Pointer.new(User32::OIC[filepath]), filepath]
      super(WinFFI::User32::Image[:ICON], filepath, name, hinstance)
    end

    class << self

      def from_file(filepath)
        new(filepath)
      end

      WinFFI::User32::OIC.symbols.each do |m|
        define_method(m.downcase, ->() { new(m) })
      end
    end
  end

  class Cursor < Resource

    alias_method :hcursor, :handle

    def initialize(filepath, hinstance = nil)
      # can't use FFI::MemoryPointer because it's freed after initialization
      # it also makes sense to use FFI::Pointer because the OIC flag isn't allocated memory
      filepath, name = filepath.is_a?(String) ?
          [filepath.to_w, filepath.split('\\').last.split('.').first] :
          [FFI::Pointer.new(User32::OCR[filepath]), filepath]
      super(WinFFI::User32::Image[:CURSOR], filepath, name, hinstance)
    end

    class << self

      def from_file(filepath)
        new(filepath)
      end

      WinFFI::User32::OCR.symbols.each do |m|
        define_method(m.downcase, ->() { new(m) })
      end
    end
  end
end
