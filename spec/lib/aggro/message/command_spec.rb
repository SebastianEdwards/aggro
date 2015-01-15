RSpec.describe Message::Command do
  TYPE_CODE = Message::Command::TYPE_CODE

  let(:sender) { SecureRandom.uuid }
  let(:commandee_id) { SecureRandom.uuid }

  let(:details) { { 'method' => 'do_thing' } }
  let(:binary_details) { MessagePack.pack(details) }
  let(:string) { TYPE_CODE + sender + commandee_id + binary_details }

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::Command.parse string

      expect(message).to be_a Message::Command
      expect(message.sender).to eq sender
      expect(message.commandee_id).to eq commandee_id
      expect(message.details).to eq details
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = Message::Command.new(sender, commandee_id, details).to_s

      expect(serialized).to eq string
    end
  end
end
