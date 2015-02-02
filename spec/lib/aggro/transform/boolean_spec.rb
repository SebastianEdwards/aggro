RSpec.describe Transform::Boolean do
  describe '.deserialize' do
    it 'should transform the value to a boolean' do
      expect(Transform::Boolean.deserialize(false)).to eq false
      expect(Transform::Boolean.deserialize(true)).to eq true
    end

    it 'should return nil if no boolean appropriate' do
      expect(Transform::Boolean.deserialize('test')).to eq nil
    end
  end

  describe '.serialize' do
    it 'should pass through value if a bool' do
      expect(Transform::Boolean.serialize(false)).to eq false
      expect(Transform::Boolean.serialize(true)).to eq true
    end

    it 'should return nil if not a bool' do
      expect(Transform::Boolean.serialize('test')).to eq nil
    end
  end
end
