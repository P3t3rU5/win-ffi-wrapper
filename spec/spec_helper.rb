require 'simplecov'
SimpleCov.start

require_relative '../test/test_helper'

WinFFI::LOGGER.level = Logger::FATAL
WinFFIWrapper::LOGGER.level = Logger::FATAL

include WinFFIWrapper