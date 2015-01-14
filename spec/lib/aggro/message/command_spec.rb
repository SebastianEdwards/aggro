RSpec.describe Message::Command do
  let(:message_type) { '1' }
  let(:sender) { SecureRandom.uuid }
  let(:commandee_id) { SecureRandom.uuid }

  let(:string) { message_type + sender + commandee_id }

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::Command.parse string

      expect(message).to be_a Message::Command
      expect(message.sender).to eq sender
      expect(message.commandee_id).to eq commandee_id
    end
  end
end
