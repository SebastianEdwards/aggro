RSpec.describe Message::CommandUnknown do
  let(:message_type) { Message::CommandUnknown::TYPE_CODE }

  let(:string) { message_type }

  describe '.new' do
    it 'should reuse the same singleton object' do
      expect(Message::CommandUnknown.new.object_id).to eq \
        Message::CommandUnknown.new.object_id
    end
  end

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::CommandUnknown.parse string

      expect(message).to be_a Message::CommandUnknown
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = Message::CommandUnknown.new.to_s

      expect(serialized).to eq string
    end
  end
end
