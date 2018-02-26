require 'win-ffi/logger'
WinFFI::LOGGER.level = Logger::INFO
require 'win-ffi/core'
require 'logger'

module WinFFIWrapper
  include WinFFI

  LOGGER = Logger.new(STDOUT)

  LOGGER.info "WinFFIWrapper v#{WinFFIWrapper::VERSION}"
end