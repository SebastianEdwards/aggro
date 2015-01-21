require 'aggro/nanomsg_transport/publish'

module Aggro
  module NanomsgTransport
    # Public: Handles publishing messages on a given endpoint.
    class Publisher
      def initialize(endpoint)
        ObjectSpace.define_finalizer self, method(:close_socket)

        @endpoint = endpoint
      end

      def close_socket
        pub_socket.terminate if @open
        @pub_socket = nil
        @open = false
      end

      def open_socket
        return @pub_socket if @open

        @open = true
        @pub_socket = Publish.new(@endpoint)
      end

      def publish(message)
        pub_socket.send_msg message
      end

      private

      def pub_socket
        @pub_socket || open_socket
      end
    end
  end
end
