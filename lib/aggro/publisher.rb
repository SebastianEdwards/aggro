module Aggro
  # Public: Publishes events over a given endpoint.
  class Publisher
    def initialize(endpoint)
      @transport_pub ||= Aggro.transport.publisher(endpoint)
    end

    def publish(topic, events)
      message = Message::Events.new(topic, events)

      @transport_pub.publish message
    end
  end
end
