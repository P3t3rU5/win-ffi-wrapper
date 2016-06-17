require 'win-ffi/core'
require 'logger'

module WinFFIWrapper
  include WinFFI

  LOGGER = Logger.new(STDOUT)

  LOGGER.info "WinFFIWrapper v#{WinFFIWrapper::VERSION}"
  LOGGER.level = Logger::INFO
end