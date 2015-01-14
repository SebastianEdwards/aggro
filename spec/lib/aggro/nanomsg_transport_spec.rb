RSpec.describe NanomsgTransport do
  let(:host) { 'tcp://127.0.0.1:6000' }
  let(:message) { SecureRandom.hex }

  it 'should work' do
    server = NanomsgTransport.server(host) { |rec| @rec = rec }.start
    client = NanomsgTransport.client host

    client.post message
    server.stop

    expect(@rec).to eq message
  end

  it 'should allow multiple clients' do
    count = 50
    server = NanomsgTransport.server(host) { |req| req }.start

    res = count.times.map { |i| NanomsgTransport.client(host).post i.to_s }
    server.stop

    expect(res.length).to eq 50
  end
end
