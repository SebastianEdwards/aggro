require 'json'

RSpec.describe Aggregate do
  class GiveSomething
    include Aggro::Command

    string :thing
  end

  class CheckThings
    include Aggro::Query
  end

  class CatSerializer
    include Aggro::Projection

    def serialize
      JSON.dump data
    end

    events do
      def gave_thing(thing)
        things << thing
      end
    end

    private

    def data
      @data ||= { things: things }
    end

    def things
      @things ||= []
    end
  end

  class Cat
    include Aggregate

    attr_reader :executed_self
    attr_reader :executed_command

    def things_i_have
      @things ||= []
    end

    projection :json, via: CatSerializer

    allows GiveSomething do |command|
      @executed_self = self
      @executed_command = command

      did.gave_thing
    end

    responds_to CheckThings do
      things_i_have
    end

    events do
      def gave_thing(thing)
        things_i_have << thing
      end
    end
  end

  subject(:aggregate) { Cat.new(id) }

  let(:id) { SecureRandom.uuid }
  let(:command) { GiveSomething.new thing: 'milk' }
  let(:query) { CheckThings.new }

  let(:existing_event) { Event.new(:gave_thing, Time.now, thing: 'cake') }
  let(:response) { Message::Events.new(id, [existing_event]) }
  let(:client) { double(post: response) }
  let(:publisher_endpoint) { 'tcp://127.0.0.1:6000' }
  let(:node) { double(client: client, publisher_endpoint: publisher_endpoint) }
  let(:fake_locator) { double primary_node: node }
  let(:locator_class) { double new: fake_locator }

  let(:id) { SecureRandom.uuid }

  let(:fake_server) { spy publish: true }

  before do
    stub_const 'Aggro::Locator', locator_class
    allow(Aggro).to receive(:server).and_return fake_server
  end

  describe '.allows' do
    it 'should register a command handler' do
      Cat.allows(Fixnum) { true }

      expect(Cat.allows?(1)).to be_truthy
    end
  end

  describe '.allows?' do
    context 'input command has a registeded handler' do
      it 'should return true' do
        expect(Cat.allows?(GiveSomething.new)).to be_truthy
      end
    end

    context 'input command does not have a registed handler' do
      it 'should return false' do
        expect(Cat.allows?('')).to be_falsey
      end
    end
  end

  describe '.create' do
    let(:id) { SecureRandom.uuid }
    let(:aggregate_ref) { double create: true }
    let(:aggregate_ref_class) { spy(new: aggregate_ref) }
    let(:response) { Message::OK.new }

    before do
      stub_const 'Aggro::Locator', locator_class
      stub_const 'Aggro::AggregateRef', aggregate_ref_class
    end

    it 'should send a CreateAggregate message to the relavent node' do
      Cat.create id

      expect(aggregate_ref).to have_received(:create)
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

  describe '.new' do
    let(:event_bus) { spy }

    before do
      allow(Aggro).to receive(:event_bus).and_return(event_bus)
    end

    it 'should subscribe itself to events for the given ID' do
      aggregate

      expect(event_bus).to have_received(:subscribe).with id, aggregate
    end
  end

  describe '#apply_command' do
    it 'should execute the handler with the aggregate as self' do
      aggregate.send :apply_command, command

      expect(aggregate.executed_self).to eq aggregate
    end

    it 'should execute the handler with the command as an argument' do
      aggregate.send :apply_command, command

      expect(aggregate.executed_command).to eq command
    end

    it 'should have the existing event applied' do
      expect(aggregate.things_i_have).to include 'cake'
    end

    it 'should apply events via the #did proxy' do
      aggregate.send :apply_command, command

      expect(aggregate.things_i_have).to include 'milk'
    end

    it 'should apply event to the projections' do
      aggregate.send :apply_command, command

      expect(aggregate.json.serialize).to eq '{"things":["cake","milk"]}'
    end
  end

  describe '#run_query' do
    it 'should return the result of the query method' do
      expect(aggregate.send(:run_query, query)).to eq ['cake']
    end
  end
end
