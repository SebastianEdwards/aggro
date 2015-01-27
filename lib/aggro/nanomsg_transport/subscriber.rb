require 'aggro/nanomsg_transport/subscribe'

module Aggro
  module NanomsgTransport
    # Public: Handles subscribing to messages on a given endpoint.
    class Subscriber
      class SubscriberAlreadyRunning < RuntimeError; end

      def initialize(endpoint, callable = nil, &block)
        @mutex = Mutex.new

        if callable
          @callable = callable
        elsif block_given?
          @callable = block
        else
          fail ArgumentError
        end

        ObjectSpace.define_finalizer self, method(:stop)
        @endpoint = endpoint
      end

      def add_subscription(topic)
        start unless @running

        @mutex.synchronize do
          @sub_socket.add_subscription(topic)
        end

        self
      end

      def start
        @mutex.synchronize do
          return if @running

          @sub_socket = Subscribe.new(@endpoint)
          @running = true
          @terminated = false

          start_on_thread
        end

        self
      end

      def stop
        return self unless @running

        @running = false
        sleep 0.01 until @terminated

        self
      end

      private

      def start_on_thread
        Concurrent::SingleThreadExecutor.new.post do
          while @running
            message = @sub_socket.recv_msg
            @callable.call(message) if message
          end

          @sub_socket.terminate
          @terminated = true
        end
      end
    end
  end
end
