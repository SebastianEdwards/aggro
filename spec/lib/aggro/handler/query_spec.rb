RSpec.describe Handler::Query do
  subject(:handler) { Handler::Query.new message, server }

  let(:query) { double }
  let(:queryable_id) { SecureRandom.uuid }
  let(:message) { double to_query: query, queryable_id: queryable_id }
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
      let(:client) { spy post: Message::Result.new }
      let(:node) { double id: node_id, client: client }
      let(:local) { false }

      it 'should forward the request to the correct node and return reply' do
        expect(handler.call).to be_a Message::Result
        expect(client).to have_received(:post)
      end
    end

    context 'local system knows the query' do
      context 'queryee exists on system' do
        let(:channel) { spy handles_query?: handles }

        before do
          fake_channels = { queryable_id => channel }
          stub_const 'Aggro', double(channels: fake_channels)
        end

        context 'channel understands query type' do
          let(:handles) { true }

          it 'should return Result' do
            expect(handler.call).to be_a Message::Result
          end

          it 'should forward query to the channel' do
            handler.call

            expect(channel).to have_received(:run_query).with query
          end
        end

        context 'channel does not understand query type' do
          let(:handles) { false }

          it 'should return UnhandledOperation' do
            expect(handler.call).to be_a Message::UnhandledOperation
          end
        end
      end

      context 'queryee does not exist on system' do
        it 'should return InvalidTarget' do
          expect(handler.call).to be_a Message::InvalidTarget
        end
      end
    end

    context 'local system does not know the query' do
      it 'should return UnknownOperation' do
        allow(message).to receive(:to_query).and_return(nil)

        expect(handler.call).to be_a Message::UnknownOperation
      end
    end
  end
end
