require 'aggro/nanomsg_transport/connection'

module Aggro
  module NanomsgTransport
    # Private: Wrapper for a nanomsg PUB node.
    class Publish < Connection
      def allocate_socket
        @socket = NNCore::LibNanomsg.nn_socket(NNCore::AF_SP, NNCore::NN_PUB)
        assert @socket
      end

      def set_endpoint
        assert NNCore::LibNanomsg.nn_bind(@socket, @endpoint)
      end
    end
  end
end
