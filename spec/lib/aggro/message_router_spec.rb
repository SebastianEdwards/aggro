RSpec.describe MessageRouter do
  subject(:router) { MessageRouter.new }

  let(:message) { message_class.new }
  let(:message_class) { Class.new }

  before do
    stub_const 'Aggro::MESSAGE_TYPES', '01' => message_class
  end

  describe '#attach_handler' do
    it 'should attach a given callable to handle a specific message type' do
      callable = -> (parsed) { parsed }

      router.attach_handler message_class, callable

      expect(router.handles?(message_class)).to be_truthy
    end

    it 'should attach a given block to handle a specific message type' do
      router.attach_handler(message_class) { |parsed| parsed }

      expect(router.handles?(message_class)).to be_truthy
    end
  end

  describe '#route' do
    it 'should route messages to the correct code' do
      router.attach_handler(message_class) { |msg| @msg = msg }
      router.route message

      expect(@msg).to eq message
    end
  end
end
