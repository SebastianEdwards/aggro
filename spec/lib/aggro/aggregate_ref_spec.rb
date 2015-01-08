describe AggregateRef do
  subject(:ref) { AggregateRef.new(id, type) }

  let(:id) { SecureRandom.uuid }
  let(:type) { 'type' }
  let(:node) { Node.new('flashing-sparkle', '10.0.0.70') }
  let(:node_list) { spy(nodes_for: [node], state: 'initial') }

  before do
    allow(Aggro).to receive(:node_list).and_return node_list
  end

  describe '#nodes' do
    it 'should return the nodes on which the aggregate should persist' do
      expect(ref.nodes.first.server).to eq '10.0.0.70'
    end

    it 'should memorize the lookup to reduce hashing' do
      5.times { ref.nodes }

      expect(node_list).to have_received(:nodes_for).once
    end

    it 'should forget memorized servers if ring state changes' do
      ref.nodes
      allow(node_list).to receive(:state).and_return('changed')
      ref.nodes

      expect(node_list).to have_received(:nodes_for).twice
    end
  end
end
