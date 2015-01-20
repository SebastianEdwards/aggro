RSpec.describe AggregateChannel do
  subject(:channel) { AggregateChannel.new id, 'Cat' }

  let(:id) { SecureRandom.uuid }
  let(:cat) { spy }

  before do
    stub_const 'Cat', double(new: double, allows?: allowed)
    stub_const 'Aggro::ConcurrentAggregate', double(spawn!: cat)
  end

  describe '#forward_command' do
    context 'command is allowed' do
      let(:allowed) { true }

      it 'should send the command to the aggregate mailbox' do
        channel.forward_command 'hello'

        expect(cat).to have_received(:<<).with 'hello'
      end
    end

    context 'command is not allowed' do
      let(:allowed) { false }

      it 'should not send the command to the aggregate mailbox' do
        channel.forward_command 'hello'

        expect(cat).to_not have_received(:<<).with 'hello'
      end
    end
  end

  describe '#handles_command' do
    context 'command is allowed' do
      let(:allowed) { true }

      it 'should should return true' do
        expect(channel.handles_command?('command')).to be_truthy
      end
    end

    context 'command is not allowed' do
      let(:allowed) { false }

      it 'should return false' do
        expect(channel.handles_command?('command')).to be_falsey
      end
    end
  end
end
