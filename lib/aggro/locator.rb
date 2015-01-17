module Aggro
  # Public: Locates the nodes responsible for a given entity ID.
  class Locator
    def initialize(id)
      @id = id
    end

    def local?
      primary_node.is_a? LocalNode
    end

    def nodes
      current_node_list_state = Aggro.node_list.state

      if @last_node_list_state == current_node_list_state
        @nodes ||= Aggro.node_list.nodes_for(@id)
      else
        @last_node_list_state = current_node_list_state

        @nodes = Aggro.node_list.nodes_for(@id)
      end
    end

    def primary_node
      nodes.first
    end

    def secondary_nodes
      nodes[1..-1]
    end
  end
end
