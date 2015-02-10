module Aggro
  module ZeroMQTransport
    # Public: Server to handle messages from nanomsg clients.
    class Server
      DEFAULT_WORKER_COUNT = 16

      # Private: Struct to hold request workload data.
      class Workload < Struct.new(:identity, :message, :socket, :mutex)
        def finish(reply)
          mutex.synchronize do
            socket.send_string identity, ZMQ::SNDMORE
            socket.send_string '', ZMQ::SNDMORE
            socket.send_string reply.to_s
          end
        end
      end

      class ServerAlreadyRunning < RuntimeError; end

      def initialize(endpoint, callable = nil, &block)
        fail ArgumentError unless callable || block_given?

        @callable = block_given? ? block : callable
        @endpoint = endpoint
        @inproc_endpoint = "inproc://aggro-server-#{SecureRandom.hex}"
        @reply_mutex = Mutex.new
        @work_queue = Queue.new
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
        DEFAULT_WORKER_COUNT.times { @work_queue << nil }

        self
      end

      private

      def enqueue_request(socket)
        id = ''
        delimiter = ''
        message = ''

        socket.recv_string id
        socket.recv_string delimiter
        socket.recv_string message

        @work_queue << Workload.new(id, message, socket, @reply_mutex)
      end

      def respond_to_request(workload)
        return if workload.nil?

        response = '00'
        response = @callable.call(workload.message)
      ensure
        workload.finish response unless workload.nil?
      end

      def start_master
        Concurrent::SingleThreadExecutor.new.post do
          socket = ZeroMQTransport.context.socket(ZMQ::XREP)
          socket.bind @endpoint

          enqueue_request socket while @running

          socket.close
        end
      end

      def start_worker
        Concurrent::SingleThreadExecutor.new.post do
          respond_to_request @work_queue.pop while @running
        end
      end
    end
  end
end
