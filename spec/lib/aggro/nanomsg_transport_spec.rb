RSpec.describe NanomsgTransport do
  let(:host) { 'tcp://127.0.0.1:6000' }
  let(:message) { SecureRandom.hex }

  it 'should work' do
    server = NanomsgTransport.server(host) { |rec| @rec = rec }.start
    client = NanomsgTransport.client host

    client.post message

    server.stop
    client.close_socket

    expect(@rec).to eq message
  end
end
