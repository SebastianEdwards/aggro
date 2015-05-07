RSpec.describe NanomsgTransport do
  let(:message) { SecureRandom.hex }

  it 'should work for REQREP' do
    server = NanomsgTransport.server('tcp://*:8250') { |rec| @rec = rec }.start
    client = NanomsgTransport.client 'tcp://localhost:8250'

    client.post message

    server.stop
    client.close_socket

    sleep 0.1

    expect(@rec).to eq message
  end

  it 'should work for PUBSUB' do
    publisher = NanomsgTransport.publisher('tcp://*:8350')

    @reced = []

    host = 'tcp://localhost:8350'
    subscriber = NanomsgTransport.subscriber(host) { |rec| @reced << rec }
    subscriber.add_subscription('foo').start

    sleep 0.1

    publisher.publish 'foobar'
    publisher.publish 'bazbar'

    sleep 0.1

    publisher.close_socket
    subscriber.stop

    expect(@reced).to include 'foobar'
    expect(@reced).to_not include 'bazbar'
  end
end
