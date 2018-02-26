using WinFFIWrapper::StringUtils

require 'win-ffi/winmm/function/wave_form'

module WinFFI
  module Media
    def self.play_sound(file, *options)
      options = options.map { |o| o.is_a?(Symbol) ? Winmm::SoundFlag[o] : o }.reduce(0, &:|)
      Winmm.PlaySound(file, nil, options)
    end
  end
end