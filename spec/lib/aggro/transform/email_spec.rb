RSpec.describe Transform::Email do
  describe '#serialize' do
    it 'should return the value if valid' do
      email = 'me@sebastianedwards.co.nz'

      expect(Transform::Email.serialize(email)).to eq email
    end

    it 'should return nil if invalid' do
      expect(Transform::Email.serialize('not an id')).to eq nil
    end
  end
end
