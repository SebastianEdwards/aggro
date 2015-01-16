RSpec.describe Command do
  class TestCommand
    include Command

    string :thing
    validates :thing, presence: true

    integer :times
  end

  subject(:command) { TestCommand.new thing: 'puppy', times: '100' }

  describe '#to_details' do
    it 'should return a hash containing the command name and arguments' do
      expected_hash = {
        name: 'TestCommand',
        args: { thing: 'puppy', times: 100 }
      }

      expect(command.to_details).to eq expected_hash
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
