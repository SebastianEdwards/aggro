RSpec.describe Server do
  subject(:server) { Server.new(endpoint) }

  let(:endpoint) { 'tcp://127.0.0.1:5000' }
  let(:transport_server) { spy }
  let(:transport) { spy(server: transport_server) }

  before do
    allow(Aggro).to receive(:transport).and_return transport
  end

  describe '.new' do
    let(:handler) { server.method(Server::RAW_HANDLER) }

    it 'should get a server which calls handler from current transport' do
      server

      expect(transport).to have_received(:server).with(endpoint, handler)
    end

    it 'should designate a handler which responds to raw messages' do
      raw_message = Message::Heartbeat.new(SecureRandom.uuid).to_s

      expect(handler.call(raw_message)).to be_a Message::OK
    end
  end

  describe '#bind' do
    it 'should start the transport server' do
      server.bind

      expect(transport_server).to have_received(:start)
    end
  end

  describe '#handle_message' do
    let(:sender) { SecureRandom.uuid }

    context 'message is a Command' do
      let(:commandee_id) { SecureRandom.uuid }
      let(:details) { { name: 'TestCommand', args: { thing: 'puppy' } } }
      let(:message) { Message::Command.new(sender, commandee_id, details) }

      it 'should delegate to command handler' do
        handler = spy(call: true)
        handler_class = spy(new: handler)

        stub_const 'Aggro::Handler::Command', handler_class

        server.handle_message message

        expect(handler_class).to have_received(:new).with(message, server)
        expect(handler).to have_received(:call)
      end
    end

    context 'message is a Heartbeat' do
      let(:message) { Message::Heartbeat.new(sender) }

      it 'should return an OK message' do
        expect(server.handle_message(message)).to be_a Message::OK
      end
    end
  end

  describe '#stop' do
    it 'should stop the transport server' do
      server.stop

      expect(transport_server).to have_received(:stop)
    end
  end
end
