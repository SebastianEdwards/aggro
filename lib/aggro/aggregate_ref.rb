module Aggro
  # Public: Reference to an Aggregate which may be local or remote.
  class AggregateRef < Struct.new(:id, :type)
    def command(command)
      response = send_command(command)

      if response.is_a? Message::InvalidTarget
        create
        response = send_command(command)
      end

      fail 'Could not send command' unless response.is_a? Message::OK

      self
    end

    def create
      response = client.post build_create_message

      fail 'Could not create aggregate' unless response.is_a? Message::OK

      self
    end

    private

    def build_command_message(command)
      Message::Command.new(Aggro.local_node.id, id, command.to_details)
    end

    def build_create_message
      Message::CreateAggregate.new(Aggro.local_node.id, id, type)
    end

    def client
      locator.primary_node.client
    end

    def locator
      @locator ||= Locator.new(id)
    end

    def send_command(command)
      client.post build_command_message(command)
    end
  end
end
