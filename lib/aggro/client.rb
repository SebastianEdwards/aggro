module Aggro
  # Public: Makes requests against a given endpoint returning parsed responses.
  class Client
    def initialize(endpoint)
      @transport_client = Aggro.transport.client(endpoint)
    end

    def post(message)
      MessageParser.parse @transport_client.post message
    end
  end
end
