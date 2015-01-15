RSpec.describe Message::Heartbeat do
  let(:message_type) { Message::Heartbeat::TYPE_CODE }
  let(:sender) { SecureRandom.uuid }

  let(:string) { message_type + sender }

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::Heartbeat.parse string

      expect(message).to be_a Message::Heartbeat
      expect(message.sender).to eq sender
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = Message::Heartbeat.new(sender).to_s

      expect(serialized).to eq string
    end
  end
end
