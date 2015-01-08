describe Aggro do
  describe '.initialize_node_list' do
    context 'when called without args' do
      it 'should initialize the node list from env variable' do
        hash_ring = Aggro.initialize_node_list
        expect(hash_ring.nodes.map(&:server)).to include '10.0.0.1'
        expect(hash_ring.nodes.map(&:server)).to include '10.0.0.2'
      end
    end

    context 'when called with an array' do
      it 'should initialize the node list from given array' do
        hash_ring = Aggro.initialize_node_list ['10.0.0.50']
        expect(hash_ring.nodes.map(&:server)).to_not include '10.0.0.1'
        expect(hash_ring.nodes.map(&:server)).to include '10.0.0.50'
      end
    end
  end

  describe '.hash_ring' do
    it 'should return a node list' do
      expect(Aggro.node_list).to be_a NodeList
    end

    it 'should return the same hash ring every time' do
      expect(Aggro.node_list).to eq Aggro.node_list
    end
  end
end
