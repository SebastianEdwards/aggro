require 'ffi'
require 'nn-core'
require 'aggro/nanomsg_transport/socket_error'

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

        assert(nbytes)

        str = @rcv_buffer.read_pointer
        response = str.read_string(nbytes)
        NNCore::LibNanomsg.nn_freemsg str

        response
      rescue SocketError => e
        raise e unless e.errno == NNCore::EAGAIN

        nil
      end

      def terminate
        assert NNCore::LibNanomsg.nn_close(@socket)
      end

      protected

      def assert(rc)
        fail SocketError.new NNCore::LibNanomsg.nn_errno unless rc >= 0
      end

      def prepare_socket_option(value)
        if value.is_a? String
          [value, value.bytesize]
        else
          option = FFI::MemoryPointer.new(:int32)
          option.write_int(value)

          [option, 4]
        end
      end

      def set_socket_option(setting, value, level = NNCore::NN_SOL_SOCKET)
        option, option_length = prepare_socket_option(value)

        rc = NNCore::LibNanomsg.nn_setsockopt(@socket, level, setting,
                                              option, option_length)
        assert(rc)
      end
    end
  end
end
