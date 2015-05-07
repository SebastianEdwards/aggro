require 'aggro/nanomsg_transport/connection'

module Aggro
  module NanomsgTransport
    # Private: Wrapper for a nanomsg SUB node.
    class Subscribe < Connection
      def add_subscription(topic)
        set_socket_option NNCore::NN_SUB_SUBSCRIBE, topic, NNCore::NN_SUB
      end

      def allocate_socket
        @socket = NNCore::LibNanomsg.nn_socket(NNCore::AF_SP, NNCore::NN_SUB)
        assert @socket
      end

      def set_endpoint
        assert NNCore::LibNanomsg.nn_connect(@socket, @endpoint)
      end

      def setup_socket
        super

        set_socket_option NNCore::NN_RCVTIMEO, 1_000
      end
    end
  end
end
