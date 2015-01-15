RSpec.describe NanomsgTransport::SocketError do
  subject(:error) { NanomsgTransport::SocketError.new 5 }

  let(:nanomsg_api) { spy nn_strerror: 'No u' }

  before do
    stub_const 'NNCore::LibNanomsg', nanomsg_api
  end

  describe '#to_s' do
    it 'should ask nanomsg for the meaning of the errno' do
      error.to_s

      expect(nanomsg_api).to have_received(:nn_strerror).with 5
    end

    it 'should provide a human readable error message' do
      expect(error.to_s).to eq "Last nanomsg API call failed with 'No u'"
    end
  end
end
