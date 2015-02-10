RSpec.describe ZeroMQTransport do
  let(:message) { SecureRandom.hex }

  it 'should work for REQREP' do
    server = ZeroMQTransport.server('tcp://*:7250') { |rec| @rec = rec }.start
    client = ZeroMQTransport.client 'tcp://localhost:7250'

    client.post message

    server.stop
    client.close_socket

    sleep 0.1

    expect(@rec).to eq message
  end

  it 'should work for PUBSUB' do
    publisher = ZeroMQTransport.publisher('tcp://*:7350')
    publisher.open_socket

    @reced = []

    host = 'tcp://localhost:7350'
    subscriber = ZeroMQTransport.subscriber(host) { |rec| @reced << rec }
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
