module WinFFIWrapper
  class ImageList

    def initialize()
      User32.ImageList_Create
    end

  end
end