RSpec.describe Client do
  subject(:client) { Client.new(endpoint, 1) }

  let(:endpoint) { 'tcp://10.0.0.1:4000' }

  describe '#post' do
    let(:transport) { spy(client: transport_client) }
    let(:transport_client) { spy(post: 'hi') }

    before do
      allow(Aggro).to receive(:transport).and_return transport
      allow(MessageParser).to receive(:parse).and_return 'parsed'
    end

    it 'should start a server for the node using the current transport' do
      client.post 'hello'

      expect(transport).to have_received(:client).with(endpoint)
      expect(transport_client).to have_received(:post).with 'hello'
    end

    it 'should parse the response with MessageParser' do
      expect(client.post('hello')).to eq 'parsed'
    end
  end
end
