module Aggro
  module ZeroMQTransport
    # Public: Handles subscribing to messages on a given endpoint.
    class Subscriber
      class SubscriberAlreadyRunning < RuntimeError; end

      def initialize(endpoint, callable = nil, &block)
        fail ArgumentError unless callable || block_given?

        @callable = block_given? ? block : callable
        @endpoint = endpoint
        @mutex = Mutex.new
      end

      def add_subscription(topic)
        start unless @mutex.synchronize { @running }

        @mutex.synchronize { sub_socket.setsockopt ZMQ::SUBSCRIBE, topic }

        self
      end

      def start
        @mutex.synchronize do
          return self if @running

          sub_socket
          start_on_thread

          sleep 0.01 until @running
        end

        self
      end

      def stop
        @mutex.synchronize do
          return self unless @running

          @running = false
        end

        self
      end

      private

      def handle_message
        message = ''
        sub_socket.recv_string message

        @callable.call message if message.present?
      end

      def sub_socket
        @sub_socket ||= begin
          socket = ZeroMQTransport.context.socket(ZMQ::SUB)
          socket.connect @endpoint

          socket
        end
      end

      def start_on_thread
        Concurrent.configuration.global_task_pool.post do
          poller = ZeroMQ::Poller.new
          poller.register_readable sub_socket

          @running = true

          (handle_message while poller.poll(1) > 0) while @running

          poller.deregister_readable sub_socket

          sub_socket.close
          @sub_socket = nil
        end
      end
    end
  end
end
