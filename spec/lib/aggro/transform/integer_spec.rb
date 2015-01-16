RSpec.describe Transform::Integer do
  describe '.deserialize' do
    it 'should transform the value to a fixnum' do
      expect(Transform::Integer.deserialize(666)).to eq 666
      expect(Transform::Integer.deserialize('200')).to eq 200
    end

    it 'should ignore extraneous characters' do
      expect(Transform::Integer.deserialize('$6,000')).to eq 6000
    end

    it 'should round decimals down to nearest integer' do
      expect(Transform::Integer.deserialize('8.0000')).to eq 8
      expect(Transform::Integer.deserialize('6.4')).to eq 6
      expect(Transform::Integer.deserialize('9.6')).to eq 9
      expect(Transform::Integer.deserialize(12.7)).to eq 12
    end

    it 'should return nil if no number appropriate' do
      expect(Transform::Integer.deserialize('test')).to eq nil
    end
  end

  describe '.serialize' do
    it 'should transform the value to a fixnum' do
      expect(Transform::Integer.serialize(666)).to eq 666
      expect(Transform::Integer.serialize('200')).to eq 200
    end
  end
end
