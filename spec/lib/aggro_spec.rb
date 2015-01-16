RSpec.describe Aggro do
  describe '.node_list' do
    let(:nodes) { { 'fluffy' => '10.0.0.50' } }
    let(:is_server_node) { true }
    let(:fake_config) do
      double(
        node_name: 'kittens',
        nodes: nodes,
        server_node?: is_server_node
      )
    end

    before do
      allow(Aggro).to receive(:cluster_config).and_return(fake_config)
    end

    it 'should return a node list' do
      expect(Aggro.node_list).to be_a NodeList
    end

    it 'should initialize the node list with nodes from cluster config' do
      expect(Aggro.node_list.nodes.map(&:id)).to include 'fluffy'
    end

    it 'should return the same node list every time' do
      expect(Aggro.node_list).to eq Aggro.node_list
    end

    context 'configured to be a server node' do
      it 'should initialize the node list with the local node' do
        expect(Aggro.node_list.nodes.map(&:id)).to include 'kittens'
      end
    end

    context 'not configured to be a server node' do
      let(:is_server_node) { false }

      it 'should not initialize the node list with the local node' do
        expect(Aggro.node_list.nodes.map(&:id)).to_not include 'kittens'
      end
    end
  end

  describe '.cluster_config' do
    it 'should return a cluster config' do
      expect(Aggro.cluster_config).to be_a ClusterConfig
    end

    it 'should return the same config every time' do
      expect(Aggro.cluster_config).to eq Aggro.cluster_config
    end
  end
end
