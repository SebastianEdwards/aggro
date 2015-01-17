RSpec.describe Transform::ID do
  REGEX = Transform::ID::ID_REGEX

  context 'generate flag is true' do
    subject(:transformer) { Transform::ID.new generate: true }

    describe '#deserialize' do
      it 'should return the value if valid ID value' do
        id = SecureRandom.uuid

        expect(transformer.deserialize(id)).to eq id
      end

      it 'should generate a new ID if invalid value' do
        expect(transformer.deserialize('not an id')).to_not eq 'not an id'
        expect(transformer.deserialize('not an id')).to match REGEX
      end

      it 'should generate a new ID if nil value' do
        expect(transformer.deserialize(nil)).to_not eq nil
        expect(transformer.deserialize(nil)).to match REGEX
      end
    end

    describe '#serialize' do
      it 'should return the value if valid' do
        id = SecureRandom.uuid

        expect(transformer.serialize(id)).to eq id
      end

      it 'should return a generated ID if invalid' do
        expect(transformer.serialize('not an id')).to_not eq 'not an id'
        expect(transformer.serialize('not an id')).to match REGEX
      end
    end
  end

  context 'generate flag is false or unset' do
    subject(:transformer) { Transform::ID.new }

    describe '#deserialize' do
      it 'should return the value if valid ID value' do
        id = SecureRandom.uuid

        expect(transformer.deserialize(id)).to eq id
      end

      it 'should return nil if invalid value' do
        expect(transformer.deserialize('not an id')).to eq nil
      end

      it 'should return nil if nil value' do
        expect(transformer.deserialize(nil)).to eq nil
      end
    end

    describe '#serialize' do
      it 'should return the value if valid' do
        id = SecureRandom.uuid

        expect(transformer.serialize(id)).to eq id
      end

      it 'should return nil if invalid' do
        expect(transformer.serialize('not an id')).to eq nil
      end
    end
  end
end
