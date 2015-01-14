require 'aggro/nanomsg_transport/reply'

module Aggro
  module NanomsgTransport
    # Public: Server to handle messages from nanomsg clients.
    class Server
      class ServerAlreadyRunning < RuntimeError; end

      def initialize(endpoint, &block)
        fail ArgumentError unless block_given?

        ObjectSpace.define_finalizer self, method(:finalize)

        @running = false
        @endpoint = endpoint
        @block = block
      end

      def start
        fail ServerAlreadyRunning if @running

        @running = true
        @reply_socket = Reply.new(@endpoint)

        Thread.new do
          loop do
            @reply_socket.send_msg @block.call(@reply_socket.recv_msg)
          end
        end

        self
      end

      def stop
        return self unless @running

        @running = false
        @reply_socket.terminate

        self
      end

      private

      def finalize
        stop
      end
    end
  end
end
