module Aggro
  module ZeroMQTransport
    # Public: Client for making requests against a nanomsg server.
    class Client
      def initialize(endpoint)
        @endpoint = endpoint
      end

      def post(message)
        request_socket.send_string message.to_s

        response = ''
        request_socket.recv_string response

        response
      end

      def close_socket
        request_socket.close if @open
        @request_socket = nil
        @open = false
      end

      private

      def request_socket
        @request_socket ||= begin
          @open = true
          socket = ZeroMQTransport.context.socket(ZMQ::REQ)
          socket.connect @endpoint

          socket
        end
      end
    end
  end
end
