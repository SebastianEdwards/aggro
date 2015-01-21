module Aggro
  # Public: Represents the local aggro server node.
  class LocalNode < Struct.new(:id)
    def client
      @client ||= create_loopback_client
    end

    def endpoint
      "tcp://127.0.0.1:#{Aggro.port}"
    end

    def publisher_endpoint
      "tcp://127.0.0.1:#{Aggro.publisher_port}"
    end

    def to_s
      id
    end

    private

    def create_loopback_client
      ->(msg) { Aggro.server.handle_message msg }.tap do |proc|
        proc.class_eval { alias_method :post, :call }
      end
    end
  end
end
