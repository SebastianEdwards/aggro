module Aggro
  # Public: Reference to an Aggregate which may be local or remote.
  class AggregateRef
    attr_reader :id
    attr_reader :type

    def initialize(id, type)
      @id = id
      @type = type
    end

    def primary_server
      servers.first
    end

    def secondary_servers
      servers.slice(1)
    end

    def servers
      current_ring_state = Aggro.node_list.state

      if @last_ring_state == current_ring_state
        @servers ||= Aggro.node_list.nodes_for(id)
      else
        @last_ring_state = current_ring_state

        @servers = Aggro.node_list.nodes_for(id)
      end
    end
  end
end
