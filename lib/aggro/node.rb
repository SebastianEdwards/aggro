module Aggro
  # Public: Represents an aggro server node.
  class Node < Struct.new(:id, :server)
    def to_s
      id
    end
  end
end
