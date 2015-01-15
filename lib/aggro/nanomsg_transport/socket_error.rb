module Aggro
  module NanomsgTransport
    # Public: An error calling the nanomsg API.
    class SocketError < RuntimeError
      attr_reader :errno

      def initialize(errno)
        @errno = errno
      end

      def error_message
        NNCore::LibNanomsg.nn_strerror(errno)
      end

      def to_s
        "Last nanomsg API call failed with '#{error_message}'"
      end
    end
  end
end
