RSpec.describe Aggregate do
  class TestCommand
  end

  class Cat
    include Aggregate

    attr_reader :executed_self
    attr_reader :executed_command

    allows TestCommand do |command|
      @executed_self = self
      @executed_command = command
    end
  end

  subject(:aggregate) { Cat.new(id, []) }

  let(:id) { SecureRandom.uuid }
  let(:command) { TestCommand.new }

  describe '.allows' do
    it 'should register a command handler' do
      Cat.allows(Fixnum) { true }

      expect(Cat.allows?(Fixnum)).to be_truthy
    end
  end

  describe '.allows?' do
    context 'input command has a registeded handler' do
      it 'should return true' do
        expect(Cat.allows?(TestCommand)).to be_truthy
      end
    end

    context 'input command does not have a registed handler' do
      it 'should return false' do
        expect(Cat.allows?(String)).to be_falsey
      end
    end
  end

  describe '.find' do
    let(:aggregate_ref) { double }
    let(:aggregate_ref_class) { spy(new: aggregate_ref) }

    let(:id) { SecureRandom.uuid }

    before do
      stub_const 'Aggro::AggregateRef', aggregate_ref_class
    end

    it 'should return an AggregateRef for the aggregate' do
      expect(Cat.find(id)).to eq aggregate_ref
      expect(aggregate_ref_class).to have_received(:new).with id, 'Cat'
    end
  end

  describe '#apply_command' do
    it 'should execute the handler with the aggregate as self' do
      aggregate.apply_command command

      expect(aggregate.executed_self).to eq aggregate
    end

    it 'should execute the handler with the command as an argument' do
      aggregate.apply_command command

      expect(aggregate.executed_command).to eq command
    end
  end
end
