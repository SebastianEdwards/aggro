require 'nio'

require 'aggro/nanomsg_transport/reply'

module Aggro
  module NanomsgTransport
    # Public: Server to handle messages from nanomsg clients.
    class Server
      class ServerAlreadyRunning < RuntimeError; end

      def initialize(endpoint, callable = nil, &block)
        if callable
          @callable = callable
        elsif block_given?
          @callable = block
        else
          fail ArgumentError
        end

        ObjectSpace.define_finalizer self, method(:stop)
        @endpoint = endpoint
        @selector = NIO::Selector.new
      end

      def start
        fail ServerAlreadyRunning if @running

        @running = true
        start_on_thread

        sleep 0.01 while @selector.empty?

        self
      end

      def stop
        return self unless @running

        @running = false
        @selector.wakeup

        sleep 0.01 until @selector.empty?

        self
      end

      private

      def handle_request(socket)
        message = socket.recv_msg
        socket.send_msg @callable.call(message) if @running
      end

      def start_on_thread
        Concurrent::SingleThreadExecutor.new.post do
          reply_socket = Reply.new(@endpoint)
          io = IO.new(reply_socket.recv_fd)

          @selector.register io, :r

          @selector.select { handle_request(reply_socket) } while @running

          @selector.deregister io
          reply_socket.terminate
        end
      end
    end
  end
end
