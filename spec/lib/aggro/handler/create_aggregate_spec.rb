RSpec.describe Handler::CreateAggregate do
  subject(:handler) { Handler::CreateAggregate.new message, server }

  let(:type) { 'Test' }
  let(:id) { SecureRandom.uuid }
  let(:message) { double id: id, type: type }
  let(:server) { double }

  let(:node) { double }
  let(:local) { true }
  let(:fake_locator) { double local?: local, primary_node: node }
  let(:locator_class) { double new: fake_locator }

  let(:fake_store) { spy(create: true) }

  before do
    stub_const 'Aggro::Locator', locator_class

    allow(Aggro).to receive(:store).and_return fake_store
  end

  describe '#call' do
    context 'id is handled by the server' do
      it 'should return an OK message' do
        expect(handler.call).to be_a Message::OK
      end

      it 'should create the aggregate in the current store' do
        handler.call

        expect(fake_store).to have_received(:create).with(id, type)
      end

      context 'does not exist in the channel list' do
        let(:fake_channels) { {} }

        let(:fake_channel) { double }
        let(:channel_class) { double new: fake_channel }

        before do
          allow(Aggro).to receive(:channels).and_return fake_channels
          stub_const 'Aggro::Channel', channel_class
        end

        it 'should add a channel for the aggregate to the channels' do
          handler.call

          expect(fake_channels[id]).to eq fake_channel
        end
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
