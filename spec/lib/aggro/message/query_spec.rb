RSpec.describe Message::Query do
  let(:type_code) { Message::Query::TYPE_CODE }

  let(:sender) { SecureRandom.uuid }
  let(:queryable_id) { SecureRandom.uuid }

  let(:args) { { thing: 'puppy' } }
  let(:details) { { name: 'TestQuery', args: args } }
  let(:binary_details) { Marshal.dump details }
  let(:string) { type_code + sender + queryable_id + binary_details }

  let(:message) { Message::Query.new(sender, queryable_id, details) }

  describe '.parse' do
    it 'should parse correctly' do
      message = Message::Query.parse string

      expect(message).to be_a Message::Query
      expect(message.sender).to eq sender
      expect(message.queryable_id).to eq queryable_id
      expect(message.details).to eq details
    end
  end

  describe '#name' do
    it 'should return the correct name' do
      expect(message.name).to eq 'TestQuery'
    end
  end

  describe '#to_query' do
    let(:query_instance) { double }
    let(:query_klass) { spy(new: query_instance) }

    it 'should build a Query object' do
      stub_const 'TestQuery', query_klass

      expect(message.to_query).to eq query_instance
      expect(query_klass).to have_received(:new).with args
    end
  end

  describe '#to_s' do
    it 'should serialize correctly' do
      serialized = message.to_s

      expect(serialized).to eq string
    end
  end
end
