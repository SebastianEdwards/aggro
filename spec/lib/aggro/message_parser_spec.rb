RSpec.describe MessageParser do
  subject(:router) { MessageRouter.new }

  let(:message_class) { spy(parse: double) }

  before do
    stub_const 'Aggro::MESSAGE_TYPES', '01' => message_class
  end

  describe '.parse' do
    it 'should parse messages via message parse function' do
      MessageParser.parse '01'
      expect(message_class).to have_received(:parse).with '01'
    end
  end
end
