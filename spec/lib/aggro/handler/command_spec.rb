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
      let(:client) { spy post: Message::OK.new }
      let(:node) { double id: node_id, client: client }
      let(:local) { false }

      it 'should forward the request to the correct node and return reply' do
        expect(handler.call).to be_a Message::OK
        expect(client).to have_received(:post)
      end
    end

    context 'local system knows the command' do
      context 'commandee exists on system' do
        let(:channel) { spy handles_command?: handles_command }

        before do
          fake_channels = { commandee_id => channel }
          stub_const 'Aggro', double(channels: fake_channels)
        end

        context 'channel understands command type' do
          let(:handles_command) { true }

          it 'should return OK' do
            expect(handler.call).to be_a Message::OK
          end

          it 'should forward command to the channel' do
            handler.call

            expect(channel).to have_received(:forward_command).with command
          end
        end

        context 'channel does not understand command type' do
          let(:handles_command) { false }

          it 'should return CommandUnhandled' do
            expect(handler.call).to be_a Message::CommandUnhandled
          end
        end
      end

      context 'commandee does not exist on system' do
        it 'should return InvalidTarget' do
          expect(handler.call).to be_a Message::InvalidTarget
        end
      end
    end

    context 'local system does not know the command' do
      it 'should return CommandUnknown' do
        allow(message).to receive(:to_command).and_return(nil)

        expect(handler.call).to be_a Message::CommandUnknown
      end
    end
  end
end
