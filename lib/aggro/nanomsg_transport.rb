require 'ffi'
require 'nn-core'

require 'aggro/nanomsg_transport/client'
require 'aggro/nanomsg_transport/publisher'
require 'aggro/nanomsg_transport/server'
require 'aggro/nanomsg_transport/subscriber'

module Aggro
  # Public: Transport layer over nanomsg sockets.
  module NanomsgTransport
    class << self
      attr_writer :linger
    end

    module_function

    def client(endpoint)
      Client.new endpoint
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
      NNCore::LibNanomsg.nn_term
    end
  end

  self.transport = NanomsgTransport if respond_to? :transport
end
