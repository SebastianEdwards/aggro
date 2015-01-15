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
        @terminated = false
        start_on_thread

        self
      end

      def stop
        return self unless @running

        @running = false
        sleep 0.01 until @terminated

        self
      end

      private

      def finalize
        stop
      end

      def start_on_thread
        Thread.new do
          @reply_socket = Reply.new(@endpoint)

          while @running
            message = @reply_socket.recv_msg
            @reply_socket.send_msg @block.call(message) if message
          end

          @reply_socket.terminate
          @terminated = true
        end
      end
    end
  end
end
