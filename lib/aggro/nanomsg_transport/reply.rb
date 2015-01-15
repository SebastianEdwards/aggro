require 'aggro/nanomsg_transport/connection'

module Aggro
  module NanomsgTransport
    # Private: Wrapper for a nanomsg REP node.
    class Reply < Connection
      def allocate_socket
        @socket = NNCore::LibNanomsg.nn_socket(NNCore::AF_SP, NNCore::NN_REP)
        assert @socket
      end

      def set_endpoint
        @eid = NNCore::LibNanomsg.nn_bind(@socket, @endpoint)
        assert @eid
      end
    end
  end
end
