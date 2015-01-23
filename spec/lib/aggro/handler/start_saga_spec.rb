RSpec.describe Handler::StartSaga do
  subject(:handler) { Handler::StartSaga.new message, server }

  class TestSaga
    include Saga
  end

  let(:id) { SecureRandom.uuid }
  let(:args) { { test: 'foo' } }
  let(:message) { double name: 'TestSaga', id: id, args: args }
  let(:server) { double }

  let(:node) { double }
  let(:local) { true }
  let(:fake_locator) { double local?: local, primary_node: node }
  let(:locator_class) { double new: fake_locator }

  before do
    stub_const 'Aggro::Locator', locator_class
  end

  describe '#call' do
    context 'saga is handled by the server' do
      let(:channel) { spy }

      before do
        stub_const 'Aggro::Channel', double(new: channel)
      end

      context 'channel understands command type' do
        it 'should return OK' do
          expect(handler.call).to be_a Message::OK
        end

        it 'should send :start to the channel' do
          handler.call

          expect(channel).to have_received(:forward_command).with \
            SagaRunner::StartSaga
        end
      end

      context 'saga is not handled by the server' do
        let(:node_id) { SecureRandom.uuid }
        let(:client) { spy post: Message::OK.new }
        let(:node) { double id: node_id, client: client }
        let(:local) { false }

        it 'should forward the request to the correct node and return reply' do
          expect(handler.call).to be_a Message::OK
          expect(client).to have_received(:post)
        end
      end
    end

    context 'local system does not know the command' do
      it 'should return SagaUnknown' do
        allow(message).to receive(:name).and_return('NotReal')

        expect(handler.call).to be_a Message::SagaUnknown
      end
    end
  end
end
