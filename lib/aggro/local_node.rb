module Aggro
  # Public: Represents the local aggro server node.
  class LocalNode < Struct.new(:id)
    def bind_server
      server.bind
    end

    def client
      @client ||= create_loopback_client
    end

    def endpoint
      "tcp://127.0.0.1:#{Aggro.port}"
    end

    def stop_server
      server.stop
    end

    def to_s
      id
    end

    private

    def create_loopback_client
      ->(msg) { server.handle_message msg }.tap do |proc|
        proc.class_eval { alias_method :post, :call }
      end
    end

    def server
      @server ||= Server.new(endpoint)
    end
  end
end
