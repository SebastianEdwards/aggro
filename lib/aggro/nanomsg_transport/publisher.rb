require 'aggro/nanomsg_transport/publish'

module Aggro
  module NanomsgTransport
    # Public: Handles publishing messages on a given endpoint.
    class Publisher
      def initialize(endpoint)
        @socket = Publish.new(endpoint)
      end

      def close_socket
        fail 'Already closed' unless @socket

        @socket.terminate
        @socket = nil
      end

      def publish(message)
        @socket.send_msg message
      end
    end
  end
end
