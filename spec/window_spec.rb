require_relative '../spec/spec_helper'
require_relative '../lib/win-ffi-wrapper/window'

RSpec.describe Window do
  subject { Window.new }
  describe '#initialize' do
    it 'has default values' do
      expect(subject.title).to eq ''
      expect(subject.enabled).to be true
      expect(subject.visible).to be false
      expect(subject.mousex).to be_a(Numeric)
      expect(subject.mousey).to be_a(Numeric)
      expect(subject.center_mode).to eq :manual
      expect(subject.icon).to eq Icon.sample
      expect(subject.taskbar_icon).to eq Icon.sample
      expect(subject.application_icon).to eq Icon.sample
      expect(subject.cursor).to eq Cursor.arrow
      expect(subject.state).to eq :restored

      # class
      expect(subject.can_close).to be true
      expect(subject.has_shadow).to be false

      #style
      expect(subject.can_maximize).to be true
      expect(subject.can_minimize).to be true
      expect(subject.can_resize).to be true
      expect(subject.has_context_help).to be false
      expect(subject.has_horizontal_scroll).to be false
      expect(subject.has_vertical_scroll).to be false

      # style extended
      expect(subject.can_accept_files).to be false
      expect(subject.focusable).to  be true
      expect(subject.is_pallete).to be false
      expect(subject.is_toolbox).to be false
      expect(subject.topmost).to    be false
    end
  end

  describe '#show' do
    it 'shows the window' do
      subject.on_loaded do
        expect(subject.visible).to be true
        subject.close
      end
      subject.show

    end
  end

  describe '#title=' do
    it 'changes the window title' do
      subject.on_loaded do
        expect(subject.title).to eq 'something'
        subject.title = 'something2'
        expect(subject.title).to eq 'something2'
        subject.close
      end
      subject.title = 'something'
      subject.show
    end
  end

  describe '#taskbar_icon=' do
    it 'changes the window title' do
      subject.on_loaded do
        expect(subject.taskbar_icon).to eq Icon.winlogo
        subject.taskbar_icon = nil
        expect(subject.title).to eq Icon.sample
        subject.close
      end
      subject.taskbar_icon = Icon.winlogo
      subject.show
    end
  end

end