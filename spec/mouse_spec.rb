require_relative '../spec/spec_helper'
require_relative '../lib/win-ffi-wrapper/mouse'

RSpec.describe Mouse do
  describe '::set_position' do
    it 'sets the current position of the mouse' do
      expect(Mouse.set_position(500, 500)).to be true
    end
  end

  describe '::get_position' do
    it 'gets the current position of the mouse' do
      expect(Mouse.get_position).to eq [500, 500]
    end
  end

  describe '::x' do
    it 'gets the current x position of the mouse' do
      expect(Mouse.x).to eq 500
    end
  end

  describe '::y' do
    it 'gets the current y position of the mouse' do
      expect(Mouse.y).to eq 500
    end
  end

  # describe '::hide' do
  #   it 'hides the mouse' do
  #     Mouse.hide
  #     sleep(5)
  #     expect(Mouse).to be_hidden
  #   end
  # end

  describe '::visible?' do
    it 'indicates whether mouse is visible' do
      expect(Mouse).to be_visible
    end
  end

end

