describe NodeList do
  subject(:node_list) { NodeList.new }

  let(:second_node_list) { NodeList.new }

  let(:id) { SecureRandom.uuid }

  let(:servers) { 10.times.map { |i| "localhost:#{5000 + i}" } }
  let(:nodes) { servers.map { |server| Node.new(server, server) } }

  describe '#add' do
    it 'should add the node to the list of nodes' do
      nodes.each { |node| node_list.add node }

      expect(node_list.nodes.length).to eq nodes.length
    end
  end

  describe '#nodes_for' do
    before do
      nodes.each { |node| node_list.add node }
    end

    it 'should get a number of nodes equal to the replication factor' do
      expect(node_list.nodes_for(id, 4).length).to eq 4
    end

    it 'should have a default replication factor of 3' do
      expect(node_list.nodes_for(id).length).to eq 3
    end

    it 'should give the same servers regardless of order of node addition' do
      nodes.shuffle.each { |node| second_node_list.add node }

      expect(node_list.nodes_for(id)).to eq second_node_list.nodes_for(id)
    end
  end
end
