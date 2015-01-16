require 'aggro/nanomsg_transport/client'
require 'aggro/nanomsg_transport/server'

module Aggro
  # Public: Transport layer over nanomsg sockets.
  module NanomsgTransport
    module_function

    def client(endpoint)
      Client.new endpoint
    end

    def server(endpoint, callable = nil, &block)
      Server.new endpoint, callable, &block
    end
  end
end
