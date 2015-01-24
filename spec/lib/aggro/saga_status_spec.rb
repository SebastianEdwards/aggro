RSpec.describe SagaStatus do
  subject(:status) { SagaStatus.new saga_id }
  let(:saga_id) { SecureRandom.uuid }

  let(:event_bus) { spy subscribe: true }

  before do
    allow(Aggro).to receive(:event_bus).and_return event_bus
  end

  describe '.new' do
    it 'should subscribe to the SagaRunner with the saga_runner namespace' do
      status

      expect(event_bus).to have_received(:subscribe).with saga_id, status
    end
  end

  describe 'events' do
    describe '#started' do
      it 'should put the status into a pending state' do
        status._started

        expect(status.state).to eq :pending
      end
    end

    describe '#rejected' do
      it 'should put the status into a rejected state' do
        status._rejected 'reason'

        expect(status.state).to eq :rejected
      end

      it 'should set the reason' do
        status._rejected 'reason'

        expect(status.reason).to eq 'reason'
      end
    end

    describe '#rejected' do
      it 'should put the status into a rejected state' do
        status._resolved 'value'

        expect(status.state).to eq :fulfilled
      end

      it 'should set the value' do
        status._resolved 'value'

        expect(status.value).to eq 'value'
      end
    end
  end
end
