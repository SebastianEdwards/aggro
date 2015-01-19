RSpec.describe Message::InvalidTarget do
  let(:message_type) { Message::InvalidTarget::TYPE_CODE }

  let(:string) { message_type }

  describe '.new' do
    it 'should reuse the same singleton object' do
      expect(Message::InvalidTarget.new.object_id).to eq \
        Message::InvalidTarget.new.object_id
    end
  end

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::InvalidTarget.parse string

      expect(message).to be_a Message::InvalidTarget
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = Message::InvalidTarget.new.to_s

      expect(serialized).to eq string
    end
  end
end
