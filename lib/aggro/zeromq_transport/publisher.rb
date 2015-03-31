module Aggro
  module ZeroMQTransport
    # Public: Handles publishing messages on a given endpoint.
    class Publisher
      def initialize(endpoint)
        @endpoint = endpoint
        @mutex = Mutex.new
      end

      def close_socket
        return unless @open && @pub_socket

        @pub_socket.close if @pub_socket
        @pub_socket = nil
        @open = false
      end

      def open_socket
        return @pub_socket if @open

        @open = true

        @pub_socket = ZeroMQTransport.context.socket(ZMQ::PUB)
        @pub_socket.setsockopt ZMQ::LINGER, 1_000
        @pub_socket.bind @endpoint

        @pub_socket
      end

      def publish(message)
        @mutex.synchronize do
          pub_socket.send_string message.to_s
        end
      end

      private

      def pub_socket
        @pub_socket || open_socket
      end
    end
  end
end
