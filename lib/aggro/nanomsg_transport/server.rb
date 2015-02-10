require 'nio'

require 'aggro/nanomsg_transport/raw_reply'
require 'aggro/nanomsg_transport/raw_request'
require 'aggro/nanomsg_transport/reply'

module Aggro
  module NanomsgTransport
    # Public: Server to handle messages from nanomsg clients.
    class Server
      DEFAULT_WORKER_COUNT = 16

      class ServerAlreadyRunning < RuntimeError; end

      def initialize(endpoint, callable = nil, &block)
        fail ArgumentError unless callable || block_given?

        @callable = block_given? ? block : callable
        @endpoint = endpoint
        @selectors = DEFAULT_WORKER_COUNT.times.map { NIO::Selector.new }
        @inproc_endpoint = "inproc://aggro-server-#{SecureRandom.hex}"
        @device_mutex = Mutex.new

        ObjectSpace.define_finalizer self, method(:stop)
      end

      def start
        fail ServerAlreadyRunning if @running

        @running = true
        start_master
        DEFAULT_WORKER_COUNT.times { |i| start_worker i }

        sleep 0.01 while @selectors.any?(&:empty?)

        self
      end

      def stop
        return self unless @running

        @running = false
        @selectors.each(&:wakeup)

        sleep 0.01 until @selectors.any?(&:empty?)

        @raw_reply.terminate
        @raw_request.terminate

        self
      end

      private

      def respond_to_request(message, socket)
        response = '00'
        response = @callable.call(message) if message
      ensure
        @device_mutex.synchronize { socket.send_msg response }
      end

      def handle_request(socket)
        return unless @running

        respond_to_request socket.recv_msg, socket
      end

      def start_master
        @master_thread = Concurrent::SingleThreadExecutor.new.post do
          @raw_reply = RawReply.new(@endpoint)
          @raw_request = RawRequest.new(@inproc_endpoint)

          NNCore::LibNanomsg.nn_device @raw_request.socket, @raw_reply.socket
        end
      end

      def start_worker(i)
        Concurrent::SingleThreadExecutor.new.post do
          reply = Reply.new(@inproc_endpoint)
          io = IO.new(reply.recv_fd, 'rb', autoclose: false)

          @selectors[i].register io, :r

          @selectors[i].select { handle_request(reply) } while @running

          @selectors[i].deregister io
          io.close
          reply.terminate
        end
      end
    end
  end
end
