require_relative '../../spec/spec_helper'
require_relative '../../lib/win-ffi-wrapper/resource/font'

RSpec.describe Font do

  describe '::list' do
    it 'lists all available fonts' do
      expect(Font::FAMILIES).to be_empty
      Font.list
      expect(Font::FAMILIES).not_to be_empty
    end
  end

  describe '::families' do
    it 'returns the listed families' do
      expect(Font.families).not_to be_empty
    end
  end

end