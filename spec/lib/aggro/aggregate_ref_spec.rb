RSpec.describe AggregateRef do
  subject(:ref) { AggregateRef.new(id, type) }

  let(:id) { SecureRandom.uuid }
  let(:type) { 'type' }
  let(:node) { Node.new('flashing-sparkle', '10.0.0.70') }
  let(:other_node) { Node.new('winking-tiger', '10.0.0.90') }
  let(:nodes) { [node, other_node] }
  let(:node_list) { spy(nodes_for: nodes, state: 'initial') }

  before do
    allow(Aggro).to receive(:node_list).and_return node_list
  end

  describe '#nodes' do
    it 'should return the nodes on which the aggregate should persist' do
      expect(ref.nodes.first.endpoint).to eq '10.0.0.70'
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

  describe '#primary_node' do
    it 'should return the first associated node' do
      expect(ref.primary_node).to eq node
    end
  end

  describe '#secondary_nodes' do
    it 'should return the rest of the associated nodes' do
      expect(ref.secondary_nodes).to eq [other_node]
    end
  end

  describe '#send_command' do
    let(:client) { spy }
    let(:nodes) { [double(id: 'fakey', client: client)] }

    it 'should send the command to the aggregate via the client' do
      command = double(to_details: { name: 'TestCommand' })

      ref.send_command command

      expect(client).to have_received(:post).with kind_of Message::Command
    end
  end
end
