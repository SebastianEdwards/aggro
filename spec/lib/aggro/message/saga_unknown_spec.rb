RSpec.describe Message::SagaUnknown do
  let(:message_type) { Message::SagaUnknown::TYPE_CODE }

  let(:string) { message_type }

  describe '.new' do
    it 'should reuse the same singleton object' do
      expect(Message::SagaUnknown.new.object_id).to eq \
      Message::SagaUnknown.new.object_id
    end
  end

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::SagaUnknown.parse string

      expect(message).to be_a Message::SagaUnknown
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = Message::SagaUnknown.new.to_s

      expect(serialized).to eq string
    end
  end
end
