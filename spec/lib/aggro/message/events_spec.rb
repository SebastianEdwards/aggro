RSpec.describe Message::Events do
  EVENTS_TYPE_CODE = Message::Events::TYPE_CODE

  let(:id) { SecureRandom.uuid }

  let(:event1) { Event.new :tested_pizza, Time.new, foo: 'bar' }
  let(:event2) { Event.new :tested_system, Time.new, bar: 'foo' }
  let(:events) { [event1, event2] }

  let(:binary_events) do
    events.map { |event| EventSerializer.serialize event }.join
  end
  let(:string) { EVENTS_TYPE_CODE + id + binary_events }

  let(:message) { Message::Events.new(id, events) }

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::Events.parse string

      expect(message).to be_a Message::Events
      expect(message.id).to eq id
      expect(message.events.first.name).to eq events.first.name
      expect(message.events.last.name).to eq events.last.name
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = message.to_s

      expect(serialized).to eq string
    end
  end
end
