require 'aggro/nanomsg_transport/connection'

module Aggro
  module NanomsgTransport
    # Private: Wrapper for a nanomsg REQ node.
    class Request < Connection
      def allocate_socket
        @socket = NNCore::LibNanomsg.nn_socket(NNCore::AF_SP, NNCore::NN_REQ)
        assert @socket
      end

      def set_endpoint
        assert NNCore::LibNanomsg.nn_connect(@socket, @endpoint)
      end
    end
  end
end
