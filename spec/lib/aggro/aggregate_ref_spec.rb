RSpec.describe AggregateRef do
  subject(:ref) { AggregateRef.new(id, type) }

  let(:id) { SecureRandom.uuid }
  let(:type) { 'type' }

  let(:response) { Message::OK.new }
  let(:client) { spy post: response }
  let(:node) { double(client: client) }
  let(:fake_locator) { double(primary_node: node) }

  before do
    allow(ref).to receive(:locator).and_return(fake_locator)
  end

  describe '#command' do
    it 'should send the command to the aggregate via the client' do
      command = double(to_details: { name: 'TestCommand' })

      ref.command command

      expect(client).to have_received(:post).with kind_of Message::Command
    end
  end

  describe '#create' do
    context 'the node also thinks it is the relavent node' do
      let(:response) { Message::OK.new }

      it 'should send a CreateAggregate message to the relavent node' do
        ref.create

        expect(client).to have_received(:post).with(Message::CreateAggregate)
      end
    end

    context 'the node does not think it is the right node for id' do
      let(:response) { Message::Ask.new(SecureRandom.uuid) }

      it 'should raise an error' do
        expect { ref.create }.to raise_error
      end
    end
  end
end
