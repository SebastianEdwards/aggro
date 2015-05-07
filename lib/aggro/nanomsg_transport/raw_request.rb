require 'aggro/nanomsg_transport/connection'

module Aggro
  module NanomsgTransport
    # Private: Wrapper for a nanomsg XREQ node.
    class RawRequest < Connection
      def allocate_socket
        @socket = NNCore::LibNanomsg.nn_socket(NNCore::AF_SP_RAW,
                                               NNCore::NN_REQ)
        assert @socket
      end

      def set_endpoint
        assert NNCore::LibNanomsg.nn_bind(@socket, @endpoint)
      end
    end
  end
end
