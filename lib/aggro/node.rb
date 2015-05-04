module Aggro
  # Public: Represents an aggro server node.
  class Node < Struct.new(:id, :endpoint)
    def client
      Aggro::Client.new(endpoint)
    end

    def publisher_endpoint
      @publisher_endpoint ||= discover_publisher_endpoint
    end

    def to_s
      id
    end

    private

    def discover_publisher_endpoint
      message = Message::PublisherEndpointInquiry.new(Aggro.local_node.id)
      response = client.post(message)

      if response.is_a? Message::Endpoint
        port = URI.parse(response.endpoint).port

        URI.parse(endpoint).tap { |uri| uri.port = port }.to_s
      else
        fail "Could not discover publisher endpoint for #{id}"
      end
    end
  end
end
