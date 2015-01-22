RSpec.describe ConcurrentActor do
  subject(:actor) { ConcurrentActor.new aggregate }

  let(:aggregate) { spy class: aggregate_class }

  describe '#on_message' do
    context 'the aggregate allows message' do
      let(:aggregate_class) { double allows?: true }

      it 'should send the message to the aggregate' do
        message = 'hello'

        actor.on_message message

        expect(aggregate).to have_received(:apply_command).with(message)
      end
    end

    context 'the aggregate does not allow message' do
      let(:aggregate_class) { double allows?: false }

      it 'should not send the message to the aggregate' do
        actor.on_message :terminate!

        expect(aggregate).to_not have_received(:apply_command)
      end
    end
  end
end
