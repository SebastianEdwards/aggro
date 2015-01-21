RSpec.describe Message::Endpoint do
  let(:message_type) { Message::Endpoint::TYPE_CODE }
  let(:endpoint) { SecureRandom.uuid }

  let(:string) { message_type + endpoint }

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::Endpoint.parse string

      expect(message).to be_a Message::Endpoint
      expect(message.endpoint).to eq endpoint
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = Message::Endpoint.new(endpoint).to_s

      expect(serialized).to eq string
    end
  end
end
