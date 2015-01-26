RSpec.describe ConcurrentActor do
  subject(:actor) { ConcurrentActor.new aggregate }

  let(:aggregate) { spy }

  class TestCommand
    include Command
  end

  class TestQuery
    include Query
  end

  describe '#on_message' do
    context 'the message is a command' do
      it 'should send the message to the aggregate' do
        message = TestCommand.new

        actor.on_message message

        expect(aggregate).to have_received(:apply_command).with(message)
      end
    end

    context 'the message is a query' do
      it 'should send the message to the aggregate' do
        message = TestQuery.new

        actor.on_message message

        expect(aggregate).to have_received(:run_query).with(message)
      end
    end

    context 'the message is not a query or command' do
      it 'should not send the message to the aggregate' do
        actor.on_message :terminate!

        expect(aggregate).to_not have_received(:apply_command)
        expect(aggregate).to_not have_received(:run_query)
      end
    end
  end
end
