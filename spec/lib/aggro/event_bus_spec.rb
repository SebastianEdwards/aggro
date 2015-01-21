RSpec.describe EventBus do
  subject(:event_bus) { EventBus.new }

  let(:fake_server) { spy }

  let(:topic) { SecureRandom.uuid }
  let(:event) { :event! }

  before do
    allow(Aggro).to receive(:server).and_return fake_server
  end

  describe '#publish' do
    it 'should publish an event via the given publisher' do
      event_bus.publish topic, event

      expect(fake_server).to have_received(:publish).with Message::Events
    end
  end
end
