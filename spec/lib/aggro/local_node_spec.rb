RSpec.describe LocalNode do
  subject(:node) { LocalNode.new('flashing-sparkle') }

  let(:fake_server) { spy(handle_message: 'OK') }

  describe '#client' do
    before do
      allow(Aggro).to receive(:server).and_return(fake_server)
    end

    it 'should return a Client-like object which locally routes messages' do
      node.client.post 'MSG'
      expect(fake_server).to have_received(:handle_message).with('MSG')
    end
  end

  describe '#endpoint' do
    before do
      allow(Aggro).to receive(:port).and_return 6000
    end

    it 'should have a local TCP endpoint with the correct port' do
      expect(node.endpoint).to eq 'tcp://*:6000'
    end
  end

  describe '#publisher_endpoint' do
    before do
      allow(Aggro).to receive(:publisher_port).and_return 7000
    end

    it 'should have a local TCP endpoint with the correct port' do
      expect(node.publisher_endpoint).to eq 'tcp://*:7000'
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
