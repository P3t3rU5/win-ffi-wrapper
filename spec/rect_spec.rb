require_relative '../spec/spec_helper'
require_relative '../lib/win-ffi-wrapper/rect'

RSpec.describe Rect do

  let(:left)    { 0 }
  let(:top)     { 0 }
  let(:bottom)  { 100 }
  let(:right)   { 100 }
  let(:width)   { 100 }
  let(:height)  { 100 }

  let(:center_x)  { 50 }
  let(:center_y)  { 50 }

  let(:area) { width * height }
  let(:perimeter) { 2 * width + 2 * height }

  subject { Rect.new(left, top, width, height) }

  describe '::from_center' do
    it "creates a Rect from center's point" do
      expect(Rect.from_center(center_x, center_y, width, height)).to eq subject
    end
  end

  describe '#area' do
    it 'returns the area of the rect' do
      expect(subject.area).to eq area
    end
  end

  describe '#perimeter' do
    it 'returns the perimeter of the rect' do
      expect(subject.perimeter).to eq perimeter
    end
  end

  describe '#bottom' do
    it 'returns the y + height value' do
      expect(subject.bottom).to eq (top + height)
    end
  end

  describe '#bottom=' do
    it 'It changes the height relative to y' do
      subject.y = 10
      subject.bottom = 50
      expect(subject.height).to eq 40
      expect(subject.bottom).to eq 50
    end

    it 'throws an error if bottom <= top' do
      subject.y = 10
      expect { subject.bottom = 0 }.to raise_error(ArgumentError)
      expect { subject.bottom = 10 }.to raise_error(ArgumentError)
    end
  end

  describe '#center' do
    it 'return the center of the rect' do
      expect(subject.center).to eq [center_x, center_x]
    end
  end

  describe '#center_x' do
    it 'return the x coordinate of the center of the rect' do
      expect(subject.center_x).to eq center_x
    end
  end

  describe '#center_y' do
    it 'return the y coordinate of the center of the rect' do
      expect(subject.center_y).to eq center_y
    end
  end

  describe '#center=' do
    it 'return the center of the rect' do
      subject.center = [100, 100]
      expect(subject.center).to eq [100, 100]
      expect(subject.left).to   eq 50
      expect(subject.top).to    eq 50
      expect(subject.width).to  eq width
      expect(subject.height).to eq height
      expect(subject.bottom).to eq 150
      expect(subject.right).to  eq 150
    end
  end

  describe '#include?' do
    it 'verifies if the point is inside the rect' do
      expect(subject.include?(center_x, center_y)).to  be true
      expect(subject.include?(150, 150)).to be false
    end
  end

  describe '#outside?' do
    it 'verifies if the point is inside the rect' do
      expect(subject.outside?(center_x, center_y)).to be false
      expect(subject.outside?(150, 150)).to be true
    end
  end

  describe '#to_native' do
    it 'returns a RECT struct' do
      r = RECT.new
      r.left, r.top, r.right, r.bottom = subject.x, subject.y, subject.width, subject.height
      expect(subject.to_native).to eq r
    end
  end

  describe '#vertices' do
    it 'returns vertices in strip form' do
      expect(subject.vertices).to eq [[left, top], [right, top], [left, bottom], [right, bottom]]
    end

    it 'returns vertices in strip form' do
      expect(subject.vertices(:cycle)).to eq [[left, top], [right, top], [right, bottom], [left, bottom]]
    end
  end

  describe '#to_s' do
    it 'returns the textual representation of a rect' do
      expect(subject.to_s).to eq "<Rect #{%w'left top width height'.map { |name| "#{name} = #{subject.send(name)}" }.join(', ')}>"
    end
  end
end