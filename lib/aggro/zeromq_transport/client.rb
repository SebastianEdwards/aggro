module Aggro
  module ZeroMQTransport
    # Public: Client for making requests against a nanomsg server.
    class Client
      def initialize(endpoint)
        @socket = ZeroMQTransport.context.socket(ZMQ::REQ)
        @socket.connect endpoint
      end

      def post(message)
        @socket.send_string message.to_s

        response = ''
        @socket.recv_string response

        response
      end

      def close_socket
        fail 'Already closed' unless @socket

        @socket.close
        @socket = nil
      end
    end
  end
end
