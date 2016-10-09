require_relative '../spec/spec_helper'
require_relative '../lib/win-ffi-wrapper/dialog'

RSpec.describe Dialog do
  describe '::message_box' do
    it 'displays a message box' do
      expect(Dialog.message_box('something')).to eq :OK
    end
  end

  describe '::info_box' do
    it 'displays a message box with information icon' do
      expect(Dialog.info_box('something')).to eq :OK
    end
  end

  describe '::error_box' do
    it 'displays a message box with error icon' do
      expect(Dialog.error_box('something')).to eq :OK
    end
  end

  describe '::warning_box' do
    it 'displays a message box with warning icon' do
      expect(Dialog.warning_box('something')).to eq :OK
    end
  end

  describe '::question_box' do
    it 'displays a message box with question icon' do
      expect(Dialog.question_box('something')).to eq :OK
    end
  end

end