require 'win-ffi/kernel32/function/process'

module WinFFIWrapper
  module Process

    # Helper method to determine if you're on a 64 bit version of Windows
    def self.windows_64?
      # The IsWow64Process function will return false for a 64 bit process,
      # so we check using both the address size and IsWow64Process.
    respond_to?(:IsWow64Process, true) && (FFI::Platform::ADDRESS_SIZE == 64 || (pbool = FFI::MemoryPointer.new(:int) && Kernel32.IsWow64Process(Kernel32.GetCurrentProcess, pbool) && pbool.read_int == 1))
    end
  end
end