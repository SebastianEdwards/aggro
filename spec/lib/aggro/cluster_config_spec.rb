RSpec.describe ClusterConfig do
  subject(:config) { ClusterConfig.new CLUSTER_CONFIG_PATH }

  describe '.new' do
    context 'node has an existing persisted node name' do
      it 'should use the existing node name' do
        @existing_name = ClusterConfig.new(CLUSTER_CONFIG_PATH).node_name

        expect(config.node_name).to eq @existing_name
      end
    end

    context 'node is being started for the first time' do
      it 'should generate a new node name' do
        expect(config.node_name).to be_a String
      end
    end
  end

  describe '#add_node' do
    it 'should add the node to the nodes hash' do
      config.add_node 'test-node', 'localhost:7000'

      expect(config.nodes['test-node']).to eq 'localhost:7000'
    end

    it 'should persist node list' do
      ClusterConfig.new(CLUSTER_CONFIG_PATH).add_node 'fluffy', 'localhost:80'

      expect(config.nodes['fluffy']).to eq 'localhost:80'
    end
  end
end
