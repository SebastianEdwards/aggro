RSpec.describe Message::Ask do
  let(:message_type) { Message::Ask::TYPE_CODE }
  let(:node_id) { SecureRandom.uuid }

  let(:string) { message_type + node_id }

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::Ask.parse string

      expect(message).to be_a Message::Ask
      expect(message.node_id).to eq node_id
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = Message::Ask.new(node_id).to_s

      expect(serialized).to eq string
    end
  end
end
