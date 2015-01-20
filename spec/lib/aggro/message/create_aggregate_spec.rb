RSpec.describe Message::CreateAggregate do
  let(:sender) { SecureRandom.uuid }
  let(:id) { SecureRandom.uuid }
  let(:type) { 'Test' }

  let(:string) { Message::CreateAggregate::TYPE_CODE + sender + id + type }

  let(:message) { Message::CreateAggregate.new(sender, id, type) }

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::CreateAggregate.parse string

      expect(message).to be_a Message::CreateAggregate
      expect(message.sender).to eq sender
      expect(message.id).to eq id
      expect(message.type).to eq type
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = message.to_s

      expect(serialized).to eq string
    end
  end
end
