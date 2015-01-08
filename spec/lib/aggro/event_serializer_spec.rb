describe EventSerializer do
  let(:data) { { one: 9000, two: 'pizza', three: ['foo', 123] } }
  let(:event) { Event.new 'tested_system', Time.new(2015), data }
  describe '.serialize' do
    it 'should convert a hash to some serialized form' do
      serialized = EventSerializer.serialize event

      expect(serialized).to be_a String
    end
  end

  describe '.deserialize' do
    it 'should convert serialized data back to the original form' do
      revived = EventSerializer.deserialize EventSerializer.serialize(event)

      expect(revived.name).to eq 'tested_system'

      expect(revived.occured_at).to eq Time.new(2015)

      expect(revived.details).to be_a Hash
      expect(revived.details.keys.length).to eq 3
      expect(revived.details[:one]).to eq 9000
      expect(revived.details[:two]).to eq 'pizza'
      expect(revived.details[:three].first).to eq 'foo'
      expect(revived.details[:three].last).to eq 123
    end
  end
end
