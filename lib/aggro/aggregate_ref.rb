module Aggro
  # Public: Reference to an Aggregate which may be local or remote.
  class AggregateRef
    attr_reader :id
    attr_reader :type

    def initialize(id, type)
      @id = id
      @type = type
    end

    def nodes
      current_node_list_state = Aggro.node_list.state

      if @last_node_list_state == current_node_list_state
        @nodes ||= Aggro.node_list.nodes_for(id)
      else
        @last_node_list_state = current_node_list_state

        @nodes = Aggro.node_list.nodes_for(id)
      end
    end

    def primary_node
      nodes.first
    end

    def secondary_nodes
      nodes[1..-1]
    end

    def send_command(command)
      primary_node.client.post build_command(command)
    end

    private

    def build_command(command)
      Message::Command.new(Aggro.local_node, id, command.to_details)
    end
  end
end
