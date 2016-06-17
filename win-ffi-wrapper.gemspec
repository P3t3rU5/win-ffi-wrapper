require_relative 'lib/win-ffi-wrapper/version'

Gem::Specification.new do |s|
  s.name          = 'win-ffi-wrapper'
  s.version       = WinFFIWrapper::VERSION
  s.summary       = 'FFI wrapper for Windows API'
  s.description   = 'FFI wrapper for Windows API.'
  s.license       = 'MIT'
  s.authors       = %w'P3t3rU5 SilverPhoenix99'
  s.email         = %w'pedro.megastore@gmail.com silver.phoenix99@gmail.com'
  s.homepage      = 'https://github.com/P3t3rU5/win-fii-wrapper'
  s.require_paths = %w'lib'
  s.files         = Dir['{lib/**/*.rb,*.md}']
  s.add_dependency 'facets', '~> 3'
  s.add_dependency 'win-ffi-core', '~> 1.0'
  s.add_dependency 'win-ffi-gdi32', '~> 1.0'
  s.add_dependency 'win-ffi-user32', '~> 1.0'
  s.add_dependency 'win-ffi-kernel32', '~> 1.0'
  s.add_dependency 'ducktape'
  s.post_install_message = <<-eos
+----------------------------------------------------------------------------+
  Thanks for choosing WinFFI Wrapper.

  ==========================================================================
  #{WinFFIWrapper::VERSION} Changes:
    - First Version

  ==========================================================================

  If you find any bugs, please report them on
    https://github.com/P3t3rU5/win-ffi/issues

+----------------------------------------------------------------------------+
  eos
end
