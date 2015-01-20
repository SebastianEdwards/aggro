RSpec.describe NanomsgTransport do
  let(:host) { 'tcp://127.0.0.1:7000' }
  let(:message) { SecureRandom.hex }

  it 'should work for REQREP' do
    server = NanomsgTransport.server(host) { |rec| @rec = rec }.start
    client = NanomsgTransport.client host

    client.post message

    server.stop
    client.close_socket

    expect(@rec).to eq message
  end

  it 'should work for PUBSUB' do
    publisher = NanomsgTransport.publisher(host)
    @reced = []

    subscriber = NanomsgTransport.subscriber(host) { |rec| @reced << rec }
    subscriber.add_subscription('foo').start

    sleep 0.1

    publisher.publish 'foobar'
    publisher.publish 'bazbar'

    publisher.close_socket
    subscriber.stop

    expect(@reced).to include 'foobar'
    expect(@reced).to_not include 'bazbar'
  end
end
