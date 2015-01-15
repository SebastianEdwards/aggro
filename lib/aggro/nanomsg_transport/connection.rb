require 'ffi'
require 'nn-core'

module Aggro
  module NanomsgTransport
    # Private: Base class for nanomsg socket wrappers.
    class Connection
      def initialize(endpoint)
        @endpoint = endpoint
        @rcv_buffer = FFI::MemoryPointer.new(:pointer)

        allocate_socket
        setup_socket
        set_endpoint
      end

      def setup_socket
        set_socket_option NNCore::NN_LINGER, 100
        set_socket_option NNCore::NN_SNDBUF, 131_072
        set_socket_option NNCore::NN_RCVBUF, 131_072
      end

      def send_msg(stringable)
        msg = stringable.to_s
        nbytes = NNCore::LibNanomsg.nn_send(@socket, msg, msg.bytesize, 0)
        assert(nbytes)

        nbytes
      end

      def recv_msg
        nbytes = NNCore::LibNanomsg.nn_recv(@socket, @rcv_buffer,
                                            NNCore::NN_MSG, 0)

        str = @rcv_buffer.read_pointer
        assert(nbytes)

        response = str.read_string(nbytes)
        NNCore::LibNanomsg.nn_freemsg str

        response
      end

      def terminate
        assert NNCore::LibNanomsg.nn_shutdown(@socket, @eid) if @eid
        assert NNCore::LibNanomsg.nn_close(@socket)
      end

      protected

      def assert(rc)
        fail "Last API call failed at #{caller(1)}" unless rc >= 0
      end

      def set_socket_option(setting, value)
        option = FFI::MemoryPointer.new(:int32)

        option.write_int(value)
        rc = NNCore::LibNanomsg.nn_setsockopt(@socket, NNCore::NN_SOL_SOCKET,
                                              setting, option, 4)
        assert(rc)
      end
    end
  end
end
