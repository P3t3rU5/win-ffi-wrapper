require 'win-ffi-wrapper/kernel/time'

module WinFFIWrapper
  module Time
    def get_local_time
      buffer = Kernel32::SYSTEMTIME.new
      Kernel32.GetLocalTime(buffer)
      buffer
    end

    def get_system_time
      buffer = Kernel32::SYSTEMTIME.new
      Kernel32.GetSystemTime(buffer)
      buffer
    end

    def get_system_time_adjustment
      results = []
      FFI::MemoryPointer.new(WinFFI.find_type(:dword)) do |time_adjustment|
        FFI::MemoryPointer.new(WinFFI.find_type(:dword)) do |time_increment|
          FFI::MemoryPointer.new(:bool) do |adjustment_disabled|
            Kernel32.GetSystemTimeAdjustment(time_adjustment, time_increment, adjustment_disabled)
            [time_adjustment.read_ulong, time_increment.read_ulong, adjustment_disabled.read_uchar == 1]
          end
        end
      end
      return if results[2]
      results
    end
  end
end