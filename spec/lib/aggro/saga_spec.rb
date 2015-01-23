RSpec.describe Saga do
  class PizzaMaker
    include Saga

    generate_id :pizza_id
    id :oven_id
    string :dough_type

    initial :prepare_dough

    step :prepare_dough do
      pizza = Pizza.create.command(command1)

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
      pizza = Pizza.find(pizza_id).command(command2)

      bind pizza do
        def started_to_be_made
          transition_to :cook
        end

        def failed_to_add_toppings
          reject "I couldn't topa the pizza"
        end
      end
    end

    step :cook do
      oven = Oven.find(oven_id).command(command3)

      bind oven do
        def cooked_thing
          resolve pizza_id
        end

        def failed_to_cook_thing
          reject "I couldn't cooka the pizza"
        end
      end
    end
  end

  subject(:saga) { PizzaMaker.new(oven_id: oven_id, dough_type: 'yummy') }

  let(:oven_id) { SecureRandom.uuid }

  let(:client) { spy }
  let(:node) { double(client: client) }
  let(:fake_locator) { double primary_node: node }
  let(:locator_class) { double new: fake_locator }

  let(:fake_status) { double }
  let(:saga_status_class) { double new: fake_status }

  before do
    stub_const 'Aggro::Locator', locator_class
    stub_const 'Aggro::SagaStatus', saga_status_class

    allow(client).to receive(:post).and_return Message::OK.new
  end

  describe '#start' do
    before do
      saga.start

      expect(client).to have_received(:post).with Message::StartSaga
    end

    it 'should return a SagaStatus' do
      expect(saga.start).to eq fake_status
    end
  end
end
