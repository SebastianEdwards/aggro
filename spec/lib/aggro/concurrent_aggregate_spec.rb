RSpec.describe ConcurrentAggregate do
  subject(:actor) { ConcurrentAggregate.new aggregate }

  let(:aggregate) { spy }

  class GreatCommand
    include Command
  end

  describe '#on_message' do
    context 'the message is a command' do
      it 'should send the message to the aggregate' do
        message = GreatCommand.new

        actor.on_message message

        expect(aggregate).to have_received(:apply_command).with(message)
      end
    end

    context 'the message is not a command' do
      it 'should not send the message to the aggregate' do
        actor.on_message :terminate!

        expect(aggregate).to_not have_received(:apply_command)
      end
    end
  end
end
