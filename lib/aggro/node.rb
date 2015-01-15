module Aggro
  # Public: Represents an aggro server node.
  class Node < Struct.new(:id, :endpoint)
    def client
      @client ||= Aggro::Client.new(endpoint)
    end

    def to_s
      id
    end
  end
end
