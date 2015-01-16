RSpec.describe Locator do
  subject(:locator) { Locator.new id }

  let(:id) { SecureRandom.uuid }
  let(:node) { Node.new('flashing-sparkle', '10.0.0.70') }
  let(:other_node) { Node.new('winking-tiger', '10.0.0.90') }
  let(:nodes) { [node, other_node] }
  let(:node_list) { spy(nodes_for: nodes, state: 'initial') }

  before do
    allow(Aggro).to receive(:node_list).and_return node_list
  end

  describe '#nodes' do
    it 'should return the nodes on which the aggregate should persist' do
      expect(locator.nodes.first.endpoint).to eq '10.0.0.70'
    end

    it 'should memorize the lookup to reduce hashing' do
      5.times { locator.nodes }

      expect(node_list).to have_received(:nodes_for).once
    end

    it 'should forget memorized servers if ring state changes' do
      locator.nodes
      allow(node_list).to receive(:state).and_return('changed')
      locator.nodes

      expect(node_list).to have_received(:nodes_for).twice
    end
  end

  describe '#primary_node' do
    it 'should return the first associated node' do
      expect(locator.primary_node).to eq node
    end
  end

  describe '#secondary_nodes' do
    it 'should return the rest of the associated nodes' do
      expect(locator.secondary_nodes).to eq [other_node]
    end
  end
end
