require 'spec_helper'

describe Aggro do
  describe '.initialize_hash_ring' do
    context 'when called without args' do
      it 'should initialize the hash ring from env variable' do
        hash_ring = Aggro.initialize_hash_ring
        expect(hash_ring.nodes).to include '10.0.0.1'
        expect(hash_ring.nodes).to include '10.0.0.2'
      end
    end

    context 'when called with an array' do
      it 'should initialize the hash ring from given array' do
        hash_ring = Aggro.initialize_hash_ring ['10.0.0.50']
        expect(hash_ring.nodes).to_not include '10.0.0.1'
        expect(hash_ring.nodes).to include '10.0.0.50'
      end
    end
  end

  describe '.hash_ring' do
    it 'should return a hash ring' do
      expect(Aggro.hash_ring).to be_a ConsistentHashing::Ring
    end

    it 'should return the same hash ring every time' do
      expect(Aggro.hash_ring).to eq Aggro.hash_ring
    end
  end
end
