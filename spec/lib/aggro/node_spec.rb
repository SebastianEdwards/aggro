RSpec.describe Node do
  subject(:node) { Node.new('flashing-sparkle') }

  describe '#connection' do
    it 'should return a client for the node using the current transport' do
      expect(node.connection).to be_a Client
    end
  end

  describe '#to_s' do
    let(:moved_node) { Node.new('flashing-sparkle') }
    let(:other_node) { Node.new('dancing-sparkle') }

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
