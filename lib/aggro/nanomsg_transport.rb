require 'aggro/nanomsg_transport/client'
require 'aggro/nanomsg_transport/server'

module Aggro
  # Public: Transport layer over nanomsg sockets.
  module NanomsgTransport
    module_function

    def client(endpoint)
      Client.new endpoint
    end

    def server(endpoint, &block)
      Server.new endpoint, &block
    end
  end
end
