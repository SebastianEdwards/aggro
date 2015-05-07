require 'aggro/nanomsg_transport/request'

module Aggro
  module NanomsgTransport
    # Public: Client for making requests against a nanomsg server.
    class Client
      def initialize(endpoint)
        @socket = Request.new(endpoint)
      end

      def close_socket
        fail 'Already closed' unless @socket

        @socket.terminate
        @socket = nil
      end

      def post(message)
        @socket.send_msg message

        @socket.recv_msg
      end
    end
  end
end
