RSpec.describe Handler::GetEvents do
  subject(:handler) { Handler::GetEvents.new message, server }

  let(:type) { 'Test' }
  let(:id) { SecureRandom.uuid }
  let(:message) { double id: id, from_version: 0 }
  let(:server) { double }

  let(:node) { double }
  let(:local) { true }
  let(:fake_locator) { double local?: local, primary_node: node }
  let(:locator_class) { double new: fake_locator }

  let(:stream) { double id: id, type: type, events: [] }
  let(:fake_store) { spy(read: [stream]) }

  before do
    stub_const 'Aggro::Locator', locator_class

    allow(Aggro).to receive(:store).and_return fake_store
  end

  describe '#call' do
    context 'id is handled by the server' do
      it 'should return an Events message' do
        response = handler.call

        expect(response).to be_a Message::Events
        expect(response.id).to eq id
        expect(response.events).to eq []
      end
    end

    context 'id is not handled by the server' do
      let(:node_id) { SecureRandom.uuid }
      let(:node) { double id: node_id }
      let(:local) { false }

      it 'should return Ask with another node to try' do
        expect(handler.call).to be_a Message::Ask
        expect(handler.call.node_id).to eq node_id
      end
    end
  end
end
