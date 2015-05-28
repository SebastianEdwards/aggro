RSpec.describe Query do
  class TestQuery
    include Query

    timeout 10

    string :term
    validates :term, presence: true

    integer :times
  end

  subject(:query) { TestQuery.new term: 'puppy', times: '100' }

  describe '#attributes' do
    it 'should return a hash of attributes' do
      expect(query.attributes).to be_a Hash
      expect(query.attributes[:term]).to eq 'puppy'
    end
  end

  describe '#serialized_attributes' do
    it 'should return a hash of attributes run through the transforms' do
      expect(query.serialized_attributes).to be_a Hash
      expect(query.serialized_attributes[:times]).to eq 100
    end
  end

  describe '#to_details' do
    it 'should return a hash containing the query name and arguments' do
      details = query.to_details

      expect(details).to be_a Hash
      expect(details[:name]).to eq 'TestQuery'
      expect(details[:args][:term]).to eq 'puppy'
      expect(details[:args][:times]).to eq 100
    end
  end

  describe '#valid?' do
    it 'should return true if query is valid' do
      expect(query.valid?).to be_truthy
    end

    it 'should return false if query is not valid' do
      expect(TestQuery.new.valid?).to be_falsey
    end
  end
end
