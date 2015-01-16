RSpec.describe AggregateRef do
  subject(:ref) { AggregateRef.new(id, type) }

  let(:id) { SecureRandom.uuid }
  let(:type) { 'type' }

  describe '#send_command' do
    let(:client) { spy }
    let(:node) { double(client: client) }
    let(:fake_locator) { double(primary_node: node) }

    before do
      allow(ref).to receive(:locator).and_return(fake_locator)
    end

    it 'should send the command to the aggregate via the client' do
      command = double(to_details: { name: 'TestCommand' })

      ref.send_command command

      expect(client).to have_received(:post).with kind_of Message::Command
    end
  end
end
