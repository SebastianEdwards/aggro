RSpec.describe FileStore::Writer do
  subject(:writer) { FileStore::Writer.new(data_io, index_io) }

  let(:data_content) { '' }
  let(:index_content) { '' }

  let(:data_io) { StringIO.new(data_content, 'a+b') }
  let(:index_io) { StringIO.new(index_content, 'a+b') }

  let(:id) { SecureRandom.uuid }

  let(:data) { { one: 9000, two: 'pizza', three: ['foo', 123] } }
  let(:event_one) { Event.new 'tested_system', Time.new(2015), data }
  let(:event_two) { Event.new 'logged_in', Time.new(2015, 2), data }
  let(:events) { [event_one, event_two] }

  describe '#write' do
    it 'should write event data to the data file' do
      writer.write(events)

      data_io.rewind
      expect(data_io.read.length).to be > 0
    end

    it 'should write an offsets to the index file for each event' do
      writer.write(events)

      index_io.rewind
      offsets = MessagePack::Unpacker.new(index_io).each.to_a
      expect(offsets.length).to eq 2
    end

    context 'when files already contain data' do
      let(:existing_event) { Event.new 'tested_pizza', Time.new(2014), data }
      let(:data_content) { EventSerializer.serialize(existing_event) }
      let(:index_content) { MessagePack.pack data_content.bytesize }

      it 'should write event data to the data file' do
        writer.write(events)

        data_io.rewind
        expect(data_io.read.length).to be > 0
      end

      it 'should write an offsets to the index file for each event' do
        writer.write(events)

        index_io.rewind
        offsets = MessagePack::Unpacker.new(index_io).each.to_a
        expect(offsets.length).to eq 3
      end

      it 'should write corrent offsets for each event' do
        writer.write(events)

        index_io.rewind
        offsets = MessagePack::Unpacker.new(index_io).each.to_a

        expect do
          EventSerializer.deserialize data_content[0...(offsets[0])]
          EventSerializer.deserialize data_content[offsets[0]...offsets[1]]
          EventSerializer.deserialize data_content[offsets[1]...offsets[2]]
        end.to_not raise_error
      end
    end
  end
end
