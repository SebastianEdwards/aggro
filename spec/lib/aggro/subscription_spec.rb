RSpec.describe Subscription do
  subject(:subscription) { Subscription.new topic, subscriber, ns, filters, 0 }

  let(:topic) { SecureRandom.uuid }
  let(:subscriber) { double }
  let(:ns) { :test }
  let(:filters) { { correlation_id: correlation_id } }

  let(:correlation_id) { SecureRandom.uuid }
  let(:details) {  { name: 'Sebastian', correlation_id: correlation_id } }
  let(:event) do
    double(name: 'added_contact', details: details, occured_at: Time.now)
  end

  let(:invokr) { spy }
  before { stub_const 'Invokr', invokr }

  describe '#handle_event' do
    context 'subscriber can handle the event' do
      before { allow(subscriber).to receive(:handles_event?).and_return true }

      context 'the filters match the event details' do
        it 'should call the event on the subscriber with the event details' do
          subscription.handle_event event

          expect(invokr).to have_received(:invoke).with \
            on: subscriber, method: 'test_added_contact', using: Hash
        end
      end

      context 'the filters do not match the event details' do
        let(:details) {  { name: 'Sebastian' } }

        it 'should not call the event on the subscriber' do
          subscription.handle_event event

          expect(invokr).to_not have_received(:invoke)
        end
      end
    end

    context 'subscriber cannot handle the event' do
      before { allow(subscriber).to receive(:handles_event?).and_return false }

      it 'should not call the event on the subscriber' do
        subscription.handle_event event

        expect(invokr).to_not have_received(:invoke)
      end
    end
  end
end
