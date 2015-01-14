require 'aggro/nanomsg_transport/request'

module Aggro
  module NanomsgTransport
    # Public: Client for making requests against a nanomsg server.
    class Client
      def initialize(endpoint)
        ObjectSpace.define_finalizer self, method(:finalize)

        @endpoint = endpoint
      end

      def post(message)
        request_socket.send_msg message

        request_socket.recv_msg
      end

      def close_socket
        request_socket.terminate if @open
        @request_socket = nil
      end

      private

      def finalize
        close_socket
      end

      def request_socket
        @request_socket ||= begin
          @open = true
          Request.new(@endpoint)
        end
      end
    end
  end
end
