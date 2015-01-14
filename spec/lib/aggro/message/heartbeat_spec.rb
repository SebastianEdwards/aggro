RSpec.describe Message::Heartbeat do
  let(:message_type) { '1' }
  let(:sender) { SecureRandom.uuid }

  let(:string) { message_type + sender }

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::Heartbeat.parse string

      expect(message).to be_a Message::Heartbeat
      expect(message.sender).to eq sender
    end
  end
end
