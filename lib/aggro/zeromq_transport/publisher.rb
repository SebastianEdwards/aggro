module Aggro
  module ZeroMQTransport
    # Public: Handles publishing messages on a given endpoint.
    class Publisher
      def initialize(endpoint)
        @socket = ZeroMQTransport.context.socket(ZMQ::PUB)
        @socket.setsockopt ZMQ::LINGER, 1_000
        @socket.bind endpoint
      end

      def close_socket
        fail 'Already closed' unless @socket

        @socket.close
        @socket = nil
      end

      def publish(message)
        @socket.send_string message.to_s
      end
    end
  end
end
