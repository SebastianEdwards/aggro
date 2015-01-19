RSpec.describe Message::CommandUnhandled do
  let(:message_type) { Message::CommandUnhandled::TYPE_CODE }

  let(:string) { message_type }

  describe '.new' do
    it 'should reuse the same singleton object' do
      expect(Message::CommandUnhandled.new.object_id).to eq \
      Message::CommandUnhandled.new.object_id
    end
  end

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::CommandUnhandled.parse string

      expect(message).to be_a Message::CommandUnhandled
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = Message::CommandUnhandled.new.to_s

      expect(serialized).to eq string
    end
  end
end
