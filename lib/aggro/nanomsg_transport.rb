require 'aggro/nanomsg_transport/client'
require 'aggro/nanomsg_transport/publisher'
require 'aggro/nanomsg_transport/server'
require 'aggro/nanomsg_transport/subscriber'

module Aggro
  # Public: Transport layer over nanomsg sockets.
  module NanomsgTransport
    module_function

    def client(endpoint)
      Client.new endpoint
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
end
