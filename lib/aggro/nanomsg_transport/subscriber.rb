require 'aggro/nanomsg_transport/subscribe'

module Aggro
  module NanomsgTransport
    # Public: Handles subscribing to messages on a given endpoint.
    class Subscriber
      class SubscriberAlreadyRunning < RuntimeError; end

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
      end

      def add_subscription(topic)
        sub_queue << topic

        self
      end

      def start
        fail SubscriberAlreadyRunning if @running

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

      def start_on_thread
        Thread.new do
          sub_socket = Subscribe.new(@endpoint)

          while @running
            sub_socket.add_subscription sub_queue.pop until sub_queue.empty?

            message = sub_socket.recv_msg
            @callable.call(message) if message
          end

          sub_socket.terminate
          @terminated = true
        end
      end

      def sub_queue
        @sub_queue ||= Queue.new
      end
    end
  end
end
