RSpec.describe Message::UnhandledOperation do
  let(:message_type) { Message::UnhandledOperation::TYPE_CODE }

  let(:string) { message_type }

  describe '.new' do
    it 'should reuse the same singleton object' do
      expect(Message::UnhandledOperation.new.object_id).to eq \
      Message::UnhandledOperation.new.object_id
    end
  end

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::UnhandledOperation.parse string

      expect(message).to be_a Message::UnhandledOperation
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = Message::UnhandledOperation.new.to_s

      expect(serialized).to eq string
    end
  end
end
