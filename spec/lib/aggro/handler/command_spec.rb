RSpec.describe Handler::Command do
  subject(:handler) { Handler::Command.new message, server }

  let(:command) { double }
  let(:commandee_id) { SecureRandom.uuid }
  let(:message) { double to_command: command, commandee_id: commandee_id }
  let(:server) { double }

  let(:node) { double }
  let(:local) { true }
  let(:fake_locator) { double local?: local, primary_node: node }
  let(:locator_class) { double new: fake_locator }

  before do
    stub_const 'Aggro::Locator', locator_class
  end

  describe '#call' do
    context 'comandee is not handled by the server' do
      let(:node_id) { SecureRandom.uuid }
      let(:node) { double id: node_id }
      let(:local) { false }

      it 'should return Ask with another node to try' do
        expect(handler.call).to be_a Message::Ask
        expect(handler.call.node_id).to eq node_id
      end
    end

    context 'local system knows the command' do
      context 'commandee exists on system' do
        let(:channel) { spy }

        before do
          fake_channels = { commandee_id => channel }
          stub_const 'Aggro', double(aggregate_channels: fake_channels)
        end

        it 'should return OK' do
          expect(handler.call).to be_a Message::OK
        end

        it 'should forward command to the channel' do
          handler.call

          expect(channel).to have_received(:forward_command).with command
        end
      end

      context 'commandee does not exist on system' do
        it 'should return InvalidTarget' do
          expect(handler.call).to be_a Message::InvalidTarget
        end
      end
    end

    context 'local system does not know the command' do
      it 'should return UnknownCommand' do
        allow(message).to receive(:to_command).and_return(nil)

        expect(handler.call).to be_a Message::UnknownCommand
      end
    end
  end
end
