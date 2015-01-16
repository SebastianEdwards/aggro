RSpec.describe Handler::Command do
  subject(:handler) { Handler::Command.new message, server }

  let(:command) { double }
  let(:message) { double(to_command: command) }
  let(:server) { double }

  describe '#call' do
    context 'local system knows the command' do
      it 'should return OK' do
        expect(handler.call).to be_a Message::OK
      end
    end

    context 'local system does not know the command' do
      let(:message) { double(to_command: nil) }

      it 'should return UnknownCommand' do
        expect(handler.call).to be_a Message::UnknownCommand
      end
    end
  end
end
