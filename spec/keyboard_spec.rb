require_relative '../spec/spec_helper'
require_relative '../lib/win-ffi-wrapper/keyboard'

RSpec.describe Keyboard do
  describe '::shift?' do
    it 'checks if shift is being pressed' do
      expect(Keyboard.shift?).to be false
    end
  end

  describe '::control??' do
    it 'checks if shift is being pressed' do
      expect(Keyboard.control?).to be false
    end
  end

  describe '::alt?' do
    it 'checks if shift is being pressed' do
      expect(Keyboard.alt?).to be false
    end
  end

end

