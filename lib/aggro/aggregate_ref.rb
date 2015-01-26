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

    def query(query)
      response = send_query(query)

      if response.is_a? Message::InvalidTarget
        create
        response = send_query(query)
      end

      fail 'Could not execute query' unless response.is_a? Message::Result

      response.result
    end

    private

    def build_command_message(command)
      Message::Command.new(Aggro.local_node.id, id, command.to_details)
    end

    def build_create_message
      Message::CreateAggregate.new(Aggro.local_node.id, id, type)
    end

    def build_query_message(query)
      Message::Query.new(Aggro.local_node.id, id, query.to_details)
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

    def send_query(query)
      client.post build_query_message(query)
    end
  end
end
