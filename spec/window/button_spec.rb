using WinFFI::StringUtils

require_relative '../../spec/spec_helper'
require_relative '../../lib/win-ffi-wrapper/window/control/button'

RSpec.describe Button do
  let(:window) { Window.new }
  subject { Button.new(window) }

  subject.on_click do
    subject.text = 'clicked'
  end

  window.on_loaded do
    window.close
    subject.click
    result = subject.text
  end

  before(:each) { window.on_create {
    window.add_button(subject) } }

  describe '#click' do
    result = nil


    it 'simulates a button click' do

      window.show
      expect(result).to eq 'clicked'
    end
  end

  describe '#double click' do
    it 'simulates a button double click' do
      result = nil
      subject.on_double_click do
        subject.text = 'double clicked'
        result = subject.text
      end
      window.on_loaded do
        window.close
        subject.double_click
      end
      window.show
      expect(result).to eq 'double clicked'
    end
  end

  describe '#get_check' do
    it 'gets the check state of the button' do
      window.show
      expect(subject.get_check).to eq :UNCHECKED
      window.close
    end
  end

  describe '#visible?' do
    it 'checks whether the button is visible or not' do
      window.show
      expect(subject).to be_visible
      window.close
    end
  end

  describe '#visible=' do
    it 'sets whether the button is visible or not' do
      window.show
      expect(subject).to be_visible
      subject.visible = false
      expect(subject).not_to be_visible
      window.close
    end
  end

  describe '#enabled?' do
    it 'checks whether the button is enabled or not' do
      window.show
      expect(subject).to be_enabled
      window.close
    end
  end

  describe '#enabled=' do
    it 'sets whether the button is enabled or not' do
      window.show
      expect(subject).to be_enabled
      subject.enabled = false
      expect(subject).not_to be_enabled
      window.close
    end
  end

  describe '#disable' do
    it 'disabled the button' do
      window.show
      expect(subject).to be_enabled
      subject.disable
      expect(subject).not_to be_enabled
      window.close
    end
  end

  describe '#enable' do
    it 'enables the button' do
      window.show
      expect(subject).to be_enabled
      subject.enabled = false
      expect(subject).not_to be_enabled
      subject.enable
      expect(subject).to be_enabled
      window.close
    end
  end

  describe '#toggle_enabled' do
    it 'sets whether the button is enabled or not' do
      window.show
      expect(subject).to be_enabled
      subject.toggle_enabled
      expect(subject).not_to be_enabled
      window.close
    end
  end

  describe '#focused?' do
    it 'checks whether the button is focused or not' do
      window.show
      expect(subject).not_to be_focused
      window.close
    end
  end


end