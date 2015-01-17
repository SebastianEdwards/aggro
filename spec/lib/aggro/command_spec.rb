RSpec.describe Command do
  class TestCommand
    include Command

    generate_id :thing_id

    id :owner_id
    string :thing
    validates :thing, presence: true

    integer :times
  end

  subject(:command) { TestCommand.new thing: 'puppy', times: '100' }

  describe '#attributes' do
    it 'should return a hash of attributes' do
      expect(command.attributes).to be_a Hash
      expect(command.attributes[:thing]).to eq 'puppy'
    end
  end

  describe '#serialized_attributes' do
    it 'should return a hash of attributes run through the transforms' do
      expect(command.serialized_attributes).to be_a Hash
      expect(command.serialized_attributes[:times]).to eq 100
    end
  end

  describe '#to_details' do
    it 'should return a hash containing the command name and arguments' do
      details = command.to_details

      expect(details).to be_a Hash
      expect(details[:name]).to eq 'TestCommand'
      expect(details[:args][:thing_id]).to match Transform::ID::ID_REGEX
      expect(details[:args][:thing]).to eq 'puppy'
      expect(details[:args][:times]).to eq 100
      expect(details[:args][:owner_id]).to eq nil
    end
  end

  describe '#valid?' do
    it 'should return true if command is valid' do
      expect(command.valid?).to be_truthy
    end

    it 'should return false if command is not valid' do
      expect(TestCommand.new.valid?).to be_falsey
    end
  end
end
