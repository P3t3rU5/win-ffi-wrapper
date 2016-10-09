require 'win-ffi/kernel32/function/memory'

module WinFFIWrapper
  module Memory

    # The LocalDiscard macro from winbase.h
    def LocalDiscard(mem_loc)
      Kernel32.LocalReAlloc(mem_loc, 0, :MOVEABLE)
    end
  end
end