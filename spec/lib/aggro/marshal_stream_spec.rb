RSpec.describe MarshalStream do
  let(:objects) { [1, :test, 'test'] }
  let(:io) { StringIO.new }

  describe '#each' do
    it 'should work as expected' do
      stream = MarshalStream.new(io).write(*objects)

      io.rewind
      result = stream.each.to_a

      expect(result[0]).to eq 1
      expect(result[1]).to eq :test
      expect(result[2]).to eq 'test'
    end
  end
end
