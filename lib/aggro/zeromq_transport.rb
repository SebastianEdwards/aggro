require 'aggro/zeromq_transport/client'
require 'aggro/zeromq_transport/publisher'
require 'aggro/zeromq_transport/server'
require 'aggro/zeromq_transport/subscriber'

module Aggro
  # Public: Transport layer over nanomsg sockets.
  module ZeroMQTransport
    CONTEXT = ZeroMQ::Context.new

    class << self
      attr_writer :linger
    end

    module_function

    def client(endpoint)
      Client.new endpoint
    end

    def context
      CONTEXT
    end

    def linger
      @linger ||= 1_000
    end

    def publisher(endpoint)
      Publisher.new endpoint
    end

    def server(endpoint, callable = nil, &block)
      Server.new endpoint, callable, &block
    end

    def subscriber(endpoint, callable = nil, &block)
      Subscriber.new endpoint, callable, &block
    end

    def teardown
      CONTEXT.terminate
    end
  end
end
