module Aggro
  # Public: Reference to an Aggregate which may be local or remote.
  class AggregateRef
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def server
      @server ||= Aggro.hash_ring.node_for(id)
    end
  end
end
