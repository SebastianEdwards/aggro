describe NodeList do
  subject(:node) { Node.new('flashing-sparkle', '10.0.0.70') }
  let(:moved_node) { Node.new('flashing-sparkle', '10.0.0.75') }
  let(:other_node) { Node.new('dancing-sparkle', '10.0.0.75') }

  describe '#to_s' do
    let(:ring) { ConsistentHashing::Ring.new }
    let(:hasher) { ring.method(:hash_key) }

    it 'should be consistently hashed the same if id matches' do
      expect(hasher.call(node)).to eq hasher.call(moved_node)
    end

    it 'should be consistently hashed differently if id differs' do
      expect(hasher.call(node)).to_not eq hasher.call(other_node)
    end
  end
end
