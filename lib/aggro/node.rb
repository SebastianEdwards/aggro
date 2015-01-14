module Aggro
  # Public: Represents an aggro server node.
  class Node < Struct.new(:id, :endpoint)
    def connection
      @connection ||= Aggro.transport.client(endpoint)
    end

    def to_s
      id
    end
  end
end
