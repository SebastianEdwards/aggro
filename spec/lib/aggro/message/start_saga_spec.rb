RSpec.describe Message::StartSaga do
  let(:sender) { SecureRandom.uuid }
  let(:id) { SecureRandom.uuid }

  let(:args) { { thing: 'puppy' } }
  let(:details) { { name: 'TestSaga', args: args } }
  let(:binary_details) { MessagePack.pack(details) }
  let(:type_code) { Message::StartSaga::TYPE_CODE }
  let(:string) { type_code + sender + id + binary_details }

  let(:message) { Message::StartSaga.new(sender, id, details) }

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::StartSaga.parse string

      expect(message).to be_a Message::StartSaga
      expect(message.sender).to eq sender
      expect(message.id).to eq id
      expect(message.details).to eq details
    end
  end

  describe '#name' do
    it 'should return the correct name' do
      expect(message.name).to eq 'TestSaga'
    end
  end

  describe '#to_saga' do
    let(:saga_instance) { double }
    let(:saga_klass) { spy(new: saga_instance) }

    it 'should build a Saga object' do
      stub_const 'TestSaga', saga_klass

      expect(message.to_saga).to eq saga_instance
      expect(saga_klass).to have_received(:new).with args
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = message.to_s

      expect(serialized).to eq string
    end
  end
end
