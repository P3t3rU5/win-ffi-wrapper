module WinFFIWrapper
  module Kernel32
    module Volume
      # Returns the volume type for +vol+ or the volume of the current process
      # if no volume is specified.
      #
      # Returns nil if the function fails for any reason.
      #
      def get_volume_type(vol = nil)
        buf = FFI::MemoryPointer.new(:char, 256)
        bool = Kernel32.GetVolumeInformation(vol, nil, 0, nil, nil, nil, buf, buf.size)
        bool ? buf.read_string : nil
      end
    end
  end
end