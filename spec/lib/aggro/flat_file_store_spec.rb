RSpec.describe FlatFileStore do
  subject(:store) { FlatFileStore.new STORE_DIR }

  let(:data_io) { StringIO.new }
  let(:index_io) { StringIO.new }

  let(:id) { SecureRandom.uuid }
  let(:type) { 'test' }

  let(:data) { { one: 9000, two: 'pizza', three: ['foo', 123] } }
  let(:event_one) { Event.new 'tested_system', Time.new(2015), data }
  let(:event_two) { Event.new 'logged_in', Time.new(2015, 2), data }
  let(:events) { [event_one, event_two] }

  let(:event_stream) { EventStream.new id, type, events }

  describe '#read' do
    before do
      FlatFileStore.new(STORE_DIR).create(id, type).write([event_stream])
    end

    it 'should be able to restore written data' do
      restored_stream = store.read([id]).first

      expect(restored_stream.id).to eq id
      expect(restored_stream.type).to eq type
      expect(restored_stream.events).to eq events
    end
  end

  describe '#write' do
    it 'should write data to disk' do
      expect { store.write [event_stream] }.to_not raise_error
    end
  end
end
