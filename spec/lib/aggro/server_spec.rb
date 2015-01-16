RSpec.describe Server do
  subject(:server) { Server.new(endpoint) }

  let(:endpoint) { 'tcp://127.0.0.1:5000' }
  let(:transport_server) { spy }
  let(:transport) { spy(server: transport_server) }

  before do
    allow(Aggro).to receive(:transport).and_return transport
  end

  describe '.new' do
    it 'should get a server with given endpoint from current transport' do
      server

      expect(transport).to have_received(:server).with(endpoint, anything)
    end
  end

  describe '#bind' do
    it 'should start the transport server' do
      server.bind

      expect(transport_server).to have_received(:start)
    end
  end

  describe '#stop' do
    it 'should stop the transport server' do
      server.stop

      expect(transport_server).to have_received(:stop)
    end
  end
end
