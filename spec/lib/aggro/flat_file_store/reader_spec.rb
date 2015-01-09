RSpec.describe FlatFileStore::Reader do
  subject(:reader) { FlatFileStore::Reader.new data_io, index_io }

  let(:data) { { one: 9000, two: 'pizza', three: ['foo', 123] } }
  let(:existing_event) { Event.new 'tested_pizza', Time.new(2014), data }

  let(:data_content) { EventSerializer.serialize(existing_event) }
  let(:index_content) { MessagePack.pack data_content.bytesize }

  let(:data_io) { StringIO.new(data_content, 'rb') }
  let(:index_io) { StringIO.new(index_content, 'rb') }

  describe '#read' do
    context 'files have stored events' do
      it 'should return an array of events' do
        result = reader.read

        expect(result).to be_a Array
        expect(result[0]).to eq existing_event
      end
    end

    context 'files have no content' do
      let(:data_content) { '' }
      let(:index_content) { '' }

      it 'should return an empty array' do
        expect(reader.read).to eq []
      end
    end
  end
end
