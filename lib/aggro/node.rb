module Aggro
  # Public: Value object for server node.
  class Node < Struct.new(:id, :server)
    def to_s
      id
    end
  end
end
