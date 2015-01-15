RSpec.describe Message::OK do
  let(:message_type) { Message::OK::TYPE_CODE }

  let(:string) { message_type }

  describe '.new' do
    it 'should reuse the same singleton object' do
      expect(Message::OK.new.object_id).to eq Message::OK.new.object_id
    end
  end

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::OK.parse string

      expect(message).to be_a Message::OK
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = Message::OK.new.to_s

      expect(serialized).to eq string
    end
  end
end
