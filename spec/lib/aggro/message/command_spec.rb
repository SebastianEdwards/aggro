RSpec.describe Message::Command do
  TYPE_CODE = Message::Command::TYPE_CODE

  let(:sender) { SecureRandom.uuid }
  let(:commandee_id) { SecureRandom.uuid }

  let(:args) { { thing: 'puppy' } }
  let(:details) { { name: 'TestCommand', args: args } }
  let(:binary_details) { MessagePack.pack(details) }
  let(:string) { TYPE_CODE + sender + commandee_id + binary_details }

  let(:message) { Message::Command.new(sender, commandee_id, details) }

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::Command.parse string

      expect(message).to be_a Message::Command
      expect(message.sender).to eq sender
      expect(message.commandee_id).to eq commandee_id
      expect(message.details).to eq details
    end
  end

  describe '#name' do
    it 'should return the correct name' do
      expect(message.name).to eq 'TestCommand'
    end
  end

  describe '#to_command' do
    let(:command_instance) { double }
    let(:command_klass) { spy(new: command_instance) }

    it 'should build a Command object' do
      stub_const 'TestCommand', command_klass

      expect(message.to_command).to eq command_instance
      expect(command_klass).to have_received(:new).with args
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = message.to_s

      expect(serialized).to eq string
    end
  end
end
