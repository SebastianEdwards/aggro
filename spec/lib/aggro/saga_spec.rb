RSpec.describe Saga do
  class StartPizza
    include Command

    string :dough_type
  end

  class Pizza
    include Aggregate

    allows StartPizza do
      if dough == 'yummy'
        did.started_to_be_made
      else
        did.failed_to_start_making
      end
    end

    events do
      def started_to_be_made(dough)
        @dough = dough.to_sym
      end
    end
  end

  class CookThing
    include Command

    id :thing_to_cook
    integer :cook_time

    validates :thing_to_cook, presence: true
    validates :cook_time, presence: true
  end

  class Oven
    include Aggregate

    allows CookThing do |command|
      sleep command.cook_time
      did.cooked_thing
    end
  end

  class PizzaMaker
    include Saga

    generate_id :pizza_id
    id :oven_id
    string :dough_type

    initial :prepare_dough

    step :prepare_dough do
      pizza = Pizza.create(pizza_id)
      command = StartPizza.new(dough_type: dough_type)
      pizza.send_command(command)

      bind pizza do
        def started_to_be_made
          transition_to :add_toppings
        end

        def failed_to_start_making
          reject "I couldn't makea the pizza"
        end
      end
    end

    step :add_toppings do
    end

    step :cook do
    end
  end

  subject(:saga) { PizzaMaker.new(oven_id: oven_id, dough_type: 'yummy') }

  let(:oven_id) { SecureRandom.uuid }

  let(:events_response) { Message::Events.new saga.saga_id, [] }
  let(:pizza_id) { SecureRandom.uuid }
  let(:existing_event) { Event.new(:tested_system, Time.now, {}) }
  let(:pizza_events) { Message::Events.new pizza_id, [existing_event] }
  let(:ok_response) { Message::OK.new }
  let(:client) { double post: pizza_events }
  let(:publisher_endpoint) { 'tcp://127.0.0.1:6000' }
  let(:node) { double(client: client, publisher_endpoint: publisher_endpoint) }
  let(:fake_locator) { double primary_node: node }
  let(:locator_class) { double new: fake_locator }

  before do
    stub_const 'Aggro::Locator', locator_class
  end

  describe '#apply_command' do
    let(:pizza_ref) { double send_command: true, id: pizza_id }

    before do
      allow(Pizza).to receive(:create).and_return pizza_ref
    end

    it 'should start' do
      saga.send :apply_command, :start
    end
  end

  describe '#start' do
    before do
      allow(client).to receive(:post).and_return events_response, ok_response
    end

    it 'should return a SagaPromise' do
      expect(saga.start).to be_a SagaPromise
    end
  end
end
