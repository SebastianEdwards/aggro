RSpec.describe Publisher do
  subject(:publisher) { Publisher.new(endpoint) }

  let(:endpoint) { 'tcp://10.0.0.1:6000' }
  let(:transport) { spy(publisher: transport_pub) }
  let(:transport_pub) { spy(publish: true) }

  let(:topic) { SecureRandom.uuid }
  let(:events) { [] }

  before do
    allow(Aggro).to receive(:transport).and_return transport
  end

  describe '.new' do
    it 'should start a server for the node using the current transport' do
      publisher

      expect(transport).to have_received(:publisher).with(endpoint)
    end
  end

  describe '#publish' do
    it 'publish the events in the form of a Message::Events to transport' do
      publisher.publish topic, events

      expect(transport_pub).to have_received(:publish).with Message::Events
    end
  end
end
