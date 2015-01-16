module Aggro
  # Public: Reference to an Aggregate which may be local or remote.
  class AggregateRef
    attr_reader :id
    attr_reader :type

    def initialize(id, type)
      @id = id
      @type = type
    end

    def send_command(command)
      locator.primary_node.client.post build_command(command)
    end

    private

    def build_command(command)
      Message::Command.new(Aggro.local_node, id, command.to_details)
    end

    def locator
      @locator ||= Locator.new(id)
    end
  end
end
