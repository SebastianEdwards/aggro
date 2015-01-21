RSpec.describe Message::GetEvents do
  let(:message_type) { Message::GetEvents::TYPE_CODE }
  let(:sender) { SecureRandom.uuid }
  let(:id) { SecureRandom.uuid }
  let(:from_version) { 0 }

  let(:string) { message_type + sender + id + from_version.to_s }

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::GetEvents.parse string

      expect(message).to be_a Message::GetEvents
      expect(message.sender).to eq sender
      expect(message.id).to eq id
      expect(message.from_version).to eq from_version
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = Message::GetEvents.new(sender, id, from_version).to_s

      expect(serialized).to eq string
    end

    it 'should use 0 as a default from_version' do
      serialized = Message::GetEvents.new(sender, id, nil).to_s

      expect(serialized).to eq string
    end
  end
end
