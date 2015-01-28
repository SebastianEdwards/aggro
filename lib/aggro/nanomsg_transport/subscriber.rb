require 'aggro/nanomsg_transport/subscribe'

module Aggro
  module NanomsgTransport
    # Public: Handles subscribing to messages on a given endpoint.
    class Subscriber
      class SubscriberAlreadyRunning < RuntimeError; end

      def initialize(endpoint, callable = nil, &block)
        fail ArgumentError unless callable || block_given?

        @callable = block_given? ? block : callable
        @endpoint = endpoint
        @mutex = Mutex.new
        @selector = NIO::Selector.new

        ObjectSpace.define_finalizer self, method(:stop)
      end

      def add_subscription(topic)
        start unless @running

        @mutex.synchronize do
          sub_socket.add_subscription(topic)
        end

        self
      end

      def start
        @mutex.synchronize do
          return self if @running

          @running = true
          start_on_thread

          sleep 0.01 while @selector.empty?
        end

        self
      end

      def stop
        @mutex.synchronize do
          return self unless @running

          @running = false
          @selector.wakeup

          sleep 0.01 until @selector.empty?
        end

        self
      end

      private

      def handle_message
        message = sub_socket.recv_msg
        @callable.call(message) if message
      end

      def sub_socket
        @sub_socket ||= Subscribe.new(@endpoint)
      end

      def start_on_thread
        Concurrent::SingleThreadExecutor.new.post do
          io = IO.new(sub_socket.recv_fd, 'rb', autoclose: false)
          @selector.register io, :r

          @selector.select { handle_message } while @running

          @selector.deregister io
          io.close
          sub_socket.terminate
          @sub_socket = nil
        end
      end
    end
  end
end
