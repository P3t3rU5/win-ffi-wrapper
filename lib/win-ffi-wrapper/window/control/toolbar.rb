require 'win-ffi/comctl32/constant/control_class'

module WinFFIWrapper
  module Toolbar
    include Control


    def initialize(window, &block)
      super(window, TOOLBAR_CLASS, &block)
    end



  end
end