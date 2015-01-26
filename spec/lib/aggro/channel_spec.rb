RSpec.describe Channel do
  subject(:channel) { Channel.new id, 'Cat' }

  let(:id) { SecureRandom.uuid }
  let(:cat) { spy }
  let(:cat_class) { double(new: 1, allows?: allowed, responds_to?: responds) }

  let(:allowed) { true }
  let(:responds) { true }

  before do
    stub_const 'Cat', cat_class
    stub_const 'Aggro::ConcurrentActor', double(spawn!: cat)
  end

  describe '#forward_command' do
    context 'command is allowed' do
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

  describe '#handles_command?' do
    context 'command is allowed' do
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

  describe '#handles?' do
    context 'query is allowed' do
      it 'should should return true' do
        expect(channel.handles_query?('query')).to be_truthy
      end
    end

    context 'query is not allowed' do
      let(:responds) { false }

      it 'should return false' do
        expect(channel.handles_query?('query')).to be_falsey
      end
    end
  end

  describe '#run_query' do
    context 'query is allowed' do
      it 'should send the command to the aggregate mailbox' do
        channel.run_query 'hello'

        expect(cat).to have_received(:ask).with 'hello'
      end
    end

    context 'query is not allowed' do
      let(:responds) { false }

      it 'should not send the command to the aggregate mailbox' do
        channel.run_query 'hello'

        expect(cat).to_not have_received(:ask).with 'hello'
      end
    end
  end
end
