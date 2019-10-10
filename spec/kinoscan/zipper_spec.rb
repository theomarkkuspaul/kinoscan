RSpec.describe Kinoscan::Zipper do
  let(:params) { { frames: ['./frame-1.jpg', './frame-2.jpg'], output_dest: './somewhere-out-there' } }
  let(:zipper) { described_class.new(params) }

  describe 'attributes' do

    it 'has a collection of frames' do
      expect(zipper.frames).to be_a Array
    end

    it 'has an archive destination' do
      expect(zipper.output_dest).to be_a String
    end

  end
end
