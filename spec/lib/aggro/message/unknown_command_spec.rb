RSpec.describe Message::UnknownCommand do
  let(:message_type) { Message::UnknownCommand::TYPE_CODE }

  let(:string) { message_type }

  describe '.new' do
    it 'should reuse the same singleton object' do
      expect(Message::UnknownCommand.new.object_id).to eq \
        Message::UnknownCommand.new.object_id
    end
  end

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::UnknownCommand.parse string

      expect(message).to be_a Message::UnknownCommand
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = Message::UnknownCommand.new.to_s

      expect(serialized).to eq string
    end
  end
end
