module Aggro
  # Public: Represents the local aggro server node.
  class LocalNode < Struct.new(:id)
    def to_s
      id
    end
  end
end
