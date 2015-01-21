RSpec.describe Projection do
  class CatSerializer
    include Aggro::Projection
  end

  subject(:projection) { CatSerializer.new id }

  let(:id) { SecureRandom.uuid }
  let(:fake_event_bus) { spy }

  before do
    allow(Aggro).to receive(:event_bus).and_return(fake_event_bus)
  end

  describe '.new' do
    it 'should subscribe itself to events for the given ID' do
      projection

      expect(fake_event_bus).to have_received(:subscribe).with(id, projection)
    end
  end
end
