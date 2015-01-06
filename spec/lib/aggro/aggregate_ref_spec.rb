require 'spec_helper'

describe AggregateRef do
  subject(:ref) { AggregateRef.new(id) }

  let(:id) { SecureRandom.uuid }
  let(:fake_ring) { double(node_for: '10.0.0.70') }

  before do
    allow(Aggro).to receive(:hash_ring).and_return fake_ring
  end

  describe '#server' do
    it 'should return the server on which the aggregate lives' do
      expect(ref.server).to eq '10.0.0.70'
    end

    it 'should memorize the lookup to reduce hashing' do
      expect(fake_ring).to receive(:node_for).once
      5.times { ref.server }
    end
  end
end
