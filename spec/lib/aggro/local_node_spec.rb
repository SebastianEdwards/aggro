RSpec.describe LocalNode do
  subject(:node) { LocalNode.new('flashing-sparkle') }

  describe '#bind' do
    let(:server) { spy }
    let(:transport) { spy(server: server) }

    before do
      allow(Aggro).to receive(:transport).and_return transport
    end

    it 'should start a server for the node using the current transport' do
      node.bind

      expect(transport).to have_received(:server).with(node.endpoint)
      expect(server).to have_received(:start)
    end
  end

  describe '#endpoint' do
    before do
      allow(Aggro).to receive(:port).and_return 6000
    end

    it 'should have a local TCP endpoint with the correct port' do
      expect(node.endpoint).to eq 'tcp://127.0.0.1:6000'
    end
  end

  describe '#to_s' do
    let(:moved_node) { LocalNode.new('flashing-sparkle') }
    let(:other_node) { LocalNode.new('dancing-sparkle') }

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
