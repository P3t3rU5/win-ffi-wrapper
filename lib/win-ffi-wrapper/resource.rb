require 'win-ffi/user32/enum/resource/image'
require 'win-ffi/user32/function/resource/resource'
require 'win-ffi/gdi32/function/device_context'

using WinFFI::StringUtils

module WinFFIWrapper
  class Resource
    include WinFFI
    attr_reader :handle, :name

    def initialize(resource_type, filepath, name, hinstance = nil)
      @name = name
      filepath, from_file = filepath.is_a?(String) ?
          [filepath.to_w, User32::LR_LOADFROMFILE] :
          [filepath, 0]

      @handle = WinFFI::User32.LoadImage(
          hinstance,       # hInstance must be NULL when loading from a file
          filepath,        # the icon file name
          resource_type,   # specifies that the file is an icon
          0,               # width of the image (we'll specify default later on)
          0,               # height of the image
          from_file      | # we want to load a file (as opposed to a resource)
          User32::LR_DEFAULTSIZE | # default metrics based on the type (IMAGE_ICON, 32x32)
          User32::LR_SHARED
      )

      at_exit do
        WinFFIWrapper::LOGGER.debug "Deleting #{self.class}..."
        WinFFI::Gdi32.DeleteObject(handle)
        @handle = nil
        WinFFIWrapper::LOGGER.debug "#{self.class} deleted"
      end

      def ==(other)
        self.class == other.class && @name == other.name
      end
    end
  end
end
