RSpec.describe Subscriber do
  subject(:subscriber) { Subscriber.new(endpoint, callable) }

  let(:callable) { spy }
  let(:endpoint) { 'tcp://127.0.0.1:6000' }
  let(:transport_sub) { spy }
  let(:transport) { spy(subscriber: transport_sub) }

  before do
    allow(Aggro).to receive(:transport).and_return transport
  end

  describe '.new' do
    let(:handler) { subscriber.method(Subscriber::RAW_HANDLER) }

    it 'should get a server which calls handler from current transport' do
      subscriber

      expect(transport).to have_received(:subscriber).with(endpoint, handler)
    end

    it 'should designate a handler which parses raw messages' do
      topic = SecureRandom.uuid
      raw_message = Message::Events.new(topic, []).to_s
      handler.call(raw_message)

      expect(callable).to have_received(:call).with(topic, [])
    end
  end

  describe '#bind' do
    it 'should start the transport server' do
      subscriber.bind

      expect(transport_sub).to have_received(:start)
    end
  end

  describe '#handle_message' do
    context 'message is an Events' do
      let(:topic) { SecureRandom.uuid }
      let(:message) { Message::Events.new(topic, []) }

      it 'should call the callback with the topic and events' do
        subscriber.handle_message message

        expect(callable).to have_received(:call).with(topic, [])
      end
    end
  end

  describe '#stop' do
    it 'should stop the transport server' do
      subscriber.stop

      expect(transport_sub).to have_received(:stop)
    end
  end
end
