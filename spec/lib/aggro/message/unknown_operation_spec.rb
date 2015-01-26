RSpec.describe Message::UnknownOperation do
  let(:message_type) { Message::UnknownOperation::TYPE_CODE }

  let(:string) { message_type }

  describe '.new' do
    it 'should reuse the same singleton object' do
      expect(Message::UnknownOperation.new.object_id).to eq \
        Message::UnknownOperation.new.object_id
    end
  end

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::UnknownOperation.parse string

      expect(message).to be_a Message::UnknownOperation
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = Message::UnknownOperation.new.to_s

      expect(serialized).to eq string
    end
  end
end
