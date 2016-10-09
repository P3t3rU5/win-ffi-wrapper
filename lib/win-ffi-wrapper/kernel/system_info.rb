require 'win-ffi/kernel32/function/system_info'
require 'win-ffi/kernel32/base'
require 'win-ffi/core/macro/util'

using WinFFI::StringUtils

module WinFFIWrapper
  module SystemInfo
    class << self

      # Retrieves the NetBIOS name of the local computer.
      # @return [String]
      def get_computer_name
        name = nil
        FFI::MemoryPointer.new(WinFFI.find_type(:tchar), Kernel32::MAX_COMPUTERNAME_LENGTH + 1) do |computer_name|
          FFI::MemoryPointer.new(WinFFI.find_type(:dword)) do |size|
            size.put_int32(0, 16)
            name = computer_name.read_array_of_uint16(size.read_int32).pack('U*') if Kernel32.GetComputerName(computer_name, size)
          end
        end
        name
      end

      # Expands environment-variable strings and replaces them with the values defined for the current user.
      # @param [String] string
      # @return [String]
      def expand_environment_string(string)
        result = nil
        FFI::MemoryPointer.new(WinFFI.find_type(:tchar), 20) do |destiny|
          size = Kernel32.ExpandEnvironmentStrings(string.to_w, destiny, 20)
          result = destiny.read_array_of_uint16(size - 1).pack('U*')
        end
        result
      end

      def get_system_directory
        path = nil
        FFI::MemoryPointer.new(WinFFI.find_type(:tchar), 256) do |destination|
          size = Kernel32.GetSystemDirectory(destination, 256)
          path = destination.read_array_of_uint16(size).pack('U*')
        end
        path
      end

      def get_system_windows_directory
        path = nil
        FFI::MemoryPointer.new(WinFFI.find_type(:tchar), 256) do |destination|
          size = Kernel32.GetSystemWindowsDirectory(destination, 256)
          path = destination.read_array_of_uint16(size).pack('U*')
        end
        path
      end

      def get_windows_directory
        path = nil
        FFI::MemoryPointer.new(WinFFI.find_type(:tchar), 256) do |destination|
          size = Kernel32.GetWindowsDirectory(destination, 256)
          path = destination.read_array_of_uint16(size).pack('U*')
        end
        path
      end

      def get_systemwow64_directory
        path = nil
        FFI::MemoryPointer.new(WinFFI.find_type(:tchar), 256) do |destination|
          size = Kernel32.GetSystemWow64Directory(destination, 256)
          path = destination.read_array_of_uint16(size).pack('U*')
        end
        path
      end

      def query_performance_counter
        ticks = LARGE_INTEGER.new
        ticks.QuadPart if Kernel32.QueryPerformanceCounter(ticks)
      end

      def query_performance_frequency
        frequency = LARGE_INTEGER.new
        frequency.QuadPart if Kernel32.QueryPerformanceFrequency(frequency)
      end

      def query_performance
        start_tick = query_performance_counter
        end_tick   = query_performance_counter

        (end_tick - start_tick)  * 1000000 / query_performance_frequency.to_f
      end

      def get_system_registry_quota
        FFI::MemoryPointer.new(WinFFI.find_type(:dword)) do |quota_allowed|
          FFI::MemoryPointer.new(WinFFI.find_type(:dword)) do |quota_used|
            [quota_used.read_ulong, quota_allowed.read_ulong] if Kernel32.GetSystemRegistryQuota(quota_allowed, quota_used)
          end
        end
      end

      def get_product_info
        product = nil
        FFI::MemoryPointer.new(WinFFI.find_type(:dword)) do |product_type|
          product = Kernel32::ProductType[product_type.read_ulong] if Kernel32.GetProductInfo(WindowsVersion.dwMajorVersion,
                                                                                    WindowsVersion.dwMinorVersion,
                                                                                    WindowsVersion.wServicePackMajor,
                                                                                    WindowsVersion.wServicePackMinor,
                                                                                    product_type)
        end
        product
      end

      def get_firmaware_type
        result = nil
        FFI::MemoryPointer.new(WinFFI.find_type(:dword)) do |firmware_type|
          result = Kernel32::FIRMWARE_TYPE[firmware_type.read_ulong] if Kernel32.GetFirmwareType(firmware_type)
        end
        result
      end

      def is_native_vhd_boot
        result = nil
        FFI::MemoryPointer.new(:bool) do |is_native_vhd_boot|
          result = Kernel32.IsNativeVhdBoot(is_native_vhd_boot)
          # result =  is_native_vhd_boot.read_uchar.to_i == 1
        end
        result
      end

    end
  end
end