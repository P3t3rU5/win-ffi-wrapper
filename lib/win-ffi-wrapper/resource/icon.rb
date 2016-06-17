require 'win-ffi-wrapper/resource'

using WinFFI::StringUtils

module WinFFIWrapper
  class Icon < Resource

    alias_method :hicon, :handle

    def initialize(filepath, hinstance = nil)
      # can't use FFI::MemoryPointer because it's freed after initialization
      # it also makes sense to use FFI::Pointer because the OIC flag isn't allocated memory
      filepath, name = filepath.is_a?(String) ?
          [filepath.to_w, filepath.split('\\').last.split('.').first] :

          [FFI::Pointer.new(User32::OemIcon[filepath]), filepath]
      super(WinFFI::User32::Image[:ICON], filepath, name, hinstance)
    end

    class << self

      def from_file(filepath)
        new(filepath)
      end

      WinFFI::User32::OemIcon.symbols.each do |m|
        define_method(m.downcase, ->() { new(m) })
      end
    end
  end
end