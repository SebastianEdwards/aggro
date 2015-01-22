RSpec.describe Handler::StartSaga do
  subject(:handler) { Handler::StartSaga.new message, server }

  class TestSaga
    include Saga
  end

  let(:saga) { double saga_id: id, class: TestSaga }
  let(:id) { SecureRandom.uuid }
  let(:message) { double to_saga: saga, id: id }
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

    context 'comandee is handled by the server' do
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

          expect(channel).to have_received(:forward_command).with :start
        end
      end
    end

    context 'local system does not know the command' do
      it 'should return SagaUnknown' do
        allow(message).to receive(:to_saga).and_return(nil)

        expect(handler.call).to be_a Message::SagaUnknown
      end
    end
  end
end
