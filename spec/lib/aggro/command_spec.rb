RSpec.describe Command do
  class TestCommand
    include Command
  end

  subject(:command) { TestCommand.new }

  describe '#to_details' do
    it 'should return a hash containing the command name and arguments' do
      expected_hash = { name: 'TestCommand' }

      expect(command.to_details).to eq expected_hash
    end
  end

  describe '#valid?' do
    it 'should include the ActiveModel::Validations API' do
      expect(command).to respond_to :valid?
    end
  end
end
