module WinFFIWrapper
  module SystemInfo

    # These macros are from windef.h, but I've put them here for now
    # since they can be used in conjunction with some of the functions
    # declared in this module.

    # Returns a float indicating the major and minor version of Windows,
    # e.g. 5.1, 6.0, etc.
    #
    def self.windows_version
      version = Kernel32::GetVersion()
      major = LOBYTE(LOWORD(version))
      minor = HIBYTE(LOWORD(version))
      Float("#{major}.#{minor}")
    end

    # Custom methods that may come in handy

    # Returns true if the current platform is Vista (any variant) or Windows
    # Server 2008, i.e. major version 6, minor version 0.
    #
    def self.windows_2000?
      version = Kernel32::GetVersion()
      LOBYTE(LOWORD(version)) == 5 && HIBYTE(LOWORD(version)) == 0
    end

    # Returns true if the current platform is Windows XP or Windows XP
    # Pro, i.e. major version 5, minor version 1 (or 2 in the case of a
    # 64-bit Windows XP Pro).
    #--
    # Because of the exception for a 64-bit Windows XP Pro, we have to
    # do things the hard way. For version 2 we look for any of the suite
    # masks that might be associated with Windows 2003. If we don't find
    # any of them, assume it's Windows XP.
    #
    def self.windows_xp?
      bool = false

      buf = OSVERSIONINFOEX.new
      buf[:dwOSVersionInfoSize] = OSVERSIONINFOEX.size

      Kernel32::GetVersionExA(buf)

      major = buf[:dwMajorVersion]
      minor = buf[:dwMinorVersion]
      suite = buf[:wSuiteMask]

      # Make sure we detect a 64-bit Windows XP Pro
      if major == 5
        if minor == 1
          bool = true
        elsif minor == 2
          if (suite & VER_SUITE_BLADE == 0)          &&
              (suite & VER_SUITE_COMPUTE_SERVER == 0) &&
              (suite & VER_SUITE_DATACENTER == 0)     &&
              (suite & VER_SUITE_ENTERPRISE == 0)     &&
              (suite & VER_SUITE_STORAGE_SERVER == 0)
          then
            bool = true
          end
        else
          # Do nothing - already false
        end
      end

      bool
    end

    # Returns true if the current platform is Windows 2003 (any version).
    # i.e. major version 5, minor version 2.
    #--
    # Because of the exception for a 64-bit Windows XP Pro, we have to
    # do things the hard way. For version 2 we look for any of the suite
    # masks that might be associated with Windows 2003. If we find any
    # of them, assume it's Windows 2003.
    #
    def self.windows_2003?
      bool = false

      buf = OSVERSIONINFOEX.new
      buf[:dwOSVersionInfoSize] = OSVERSIONINFOEX.size

      Kernel32::GetVersionExA(buf)

      major = buf[:dwMajorVersion]
      minor = buf[:dwMinorVersion]
      suite = buf[:wSuiteMask]

      # Make sure we exclude a 64-bit Windows XP Pro
      if major == 5 && minor == 2
        if (suite & VER_SUITE_BLADE > 0)          ||
            (suite & VER_SUITE_COMPUTE_SERVER > 0) ||
            (suite & VER_SUITE_DATACENTER > 0)     ||
            (suite & VER_SUITE_ENTERPRISE > 0)     ||
            (suite & VER_SUITE_STORAGE_SERVER > 0)
        then
          bool = true
        end
      end

      bool
    end

    # Returns true if the current platform is Windows Vista (any variant)
    # or Windows Server 2008, i.e. major version 6, minor version 0.
    #
    def self.windows_vista?
      version = Kernel32::GetVersion()
      LOBYTE(LOWORD(version)) == 6 && HIBYTE(LOWORD(version)) == 0
    end

    def self.windows_7?
      version = Kernel32::GetVersion()
      LOBYTE(LOWORD(version)) == 6 && HIBYTE(LOWORD(version)) == 1
    end

    def self.windows_8?
      version = Kernel32::GetVersion()
      LOBYTE(LOWORD(version)) == 6 && HIBYTE(LOWORD(version)) == 2
    end

    def self.windows_8_1?
      version = Kernel32::GetVersion()
      LOBYTE(LOWORD(version)) == 6 && HIBYTE(LOWORD(version)) == 3
    end
  end
end