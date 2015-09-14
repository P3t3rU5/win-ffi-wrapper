require 'win-ffi/functions/kernel32/dll'

module WinFFIWrapper
  module DLL
    include WinFFI

    def self.module_handle(flags = :none, module_name = nil)
      hinstance = nil
      FFI::MemoryPointer.new(:pointer, 1) do |p|
        if Kernel32.GetModuleHandleExW(flags, module_name, p)
          hinstance = p.read_pointer
          hinstance = nil if hinstance.null?
        end
      end
      hinstance
    end
  end
end