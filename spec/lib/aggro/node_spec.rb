RSpec.describe Node do
  subject(:node) { Node.new('flashing-sparkle') }

  describe '#client' do
    it 'should return a client for the node using the current transport' do
      expect(node.client).to be_a Client
    end
  end

  describe '#publisher_endpoint' do
    context 'node returns an Endpoint message' do
      it 'should ask the node for the publisher endpoint' do
        endpoint = Message::Endpoint.new('endpoint')
        allow(node).to receive(:client).and_return(double post: endpoint)

        expect(node.publisher_endpoint).to eq 'endpoint'
      end
    end

    context 'node does not return an Endpoint message' do
      it 'should ask the node for the publisher endpoint' do
        allow(node).to receive(:client).and_return(double post: 'not endpoint')

        expect { node.publisher_endpoint }.to raise_error
      end
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
