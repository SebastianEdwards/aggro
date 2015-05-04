module Aggro
  # Public: Makes requests against a given endpoint returning parsed responses.
  class Client
    def initialize(endpoint)
      @transport_client = Aggro.transport.client(endpoint)
    end

    def disconnect!
      @transport_client.close_socket
    end

    def post(message)
      MessageParser.parse @transport_client.post message
    ensure
      disconnect!
    end
  end
end
