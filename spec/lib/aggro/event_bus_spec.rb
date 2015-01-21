RSpec.describe EventBus do
  subject(:event_bus) { EventBus.new fake_publisher }

  let(:fake_publisher) { spy }

  let(:topic) { SecureRandom.uuid }
  let(:event) { :event! }

  describe '#publish' do
    it 'should publish an event via the given publisher' do
      event_bus.publish topic, event

      expect(fake_publisher).to have_received(:publish).with topic, [event]
    end
  end
end
