require 'aggro/nanomsg_transport/raw_reply'
require 'aggro/nanomsg_transport/raw_request'
require 'aggro/nanomsg_transport/reply'

module Aggro
  module NanomsgTransport
    # Public: Server to handle messages from nanomsg clients.
    class Server
      DEFAULT_WORKER_COUNT = 64

      class ServerAlreadyRunning < RuntimeError; end

      def initialize(endpoint, callable = nil, &block)
        fail ArgumentError unless callable || block_given?

        @callable = block_given? ? block : callable
        @endpoint = endpoint
        @inproc_endpoint = "inproc://aggro-server-#{SecureRandom.hex}"
        @device_mutex = Mutex.new
      end

      def start
        fail ServerAlreadyRunning if @running

        @running = true
        start_master
        DEFAULT_WORKER_COUNT.times { start_worker }

        self
      end

      def stop
        return self unless @running

        @running = false

        self
      end

      private

      def respond_to_request(message, socket)
        response = '00'
        response = @callable.call(message)
      ensure
        @device_mutex.synchronize { socket.send_msg response }
      end

      def handle_request(socket)
        message = socket.recv_msg

        respond_to_request message, socket if message
      end

      def start_master
        Concurrent::SingleThreadExecutor.new.post do
          @raw_reply = RawReply.new(@endpoint)
          @raw_request = RawRequest.new(@inproc_endpoint)

          NNCore::LibNanomsg.nn_device @raw_request.socket, @raw_reply.socket
        end
      end

      def start_worker
        Concurrent::SingleThreadExecutor.new.post do
          reply = Reply.new(@inproc_endpoint)

          handle_request reply while @running

          reply.terminate
        end
      end
    end
  end
end
