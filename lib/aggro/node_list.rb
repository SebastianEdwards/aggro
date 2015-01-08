module Aggro
  # Public: Computes which nodes are responsible for a given aggregate ID.
  class NodeList
    DEFAULT_REPLICATION_FACTOR = 3

    attr_reader :state

    def add(node)
      hash_ring << node

      update_state
    end

    def nodes_for(id, replication_factor = default_replication_factor)
      nodes
        .cycle
        .take(nodes.index(hash_ring.node_for(id)) + replication_factor)
        .last(replication_factor)
    end

    def nodes
      hash_ring.nodes.sort_by(&:id)
    end

    private

    def default_replication_factor
      [nodes.length, DEFAULT_REPLICATION_FACTOR].min
    end

    def hash_ring
      @hash_ring ||= ConsistentHashing::Ring.new
    end

    def update_state
      @state = Digest::MD5.hexdigest(nodes.map(&:to_s).join)[0..16].hex
    end
  end
end
