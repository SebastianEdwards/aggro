RSpec.describe Transform::String do
  describe '.deserialize' do
    it 'should stringify the value' do
      expect(Transform::String.deserialize('test')).to eq 'test'
      expect(Transform::String.deserialize(666)).to eq '666'
    end
  end

  describe '.serialize' do
    it 'should stringify the value' do
      expect(Transform::String.serialize('test')).to eq 'test'
      expect(Transform::String.serialize(666)).to eq '666'
    end
  end
end
