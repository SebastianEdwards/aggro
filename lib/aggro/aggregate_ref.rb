module Aggro
  # Public: Reference to an Aggregate which may be local or remote.
  class AggregateRef
    attr_reader :id, :type

    def initialize(id, type)
      @id = id
      @type = type
    end

    def command(command, create_on_unknown: true)
      response = send_command(command)

      if response.is_a?(Message::InvalidTarget) && create_on_unknown
        create
        response = send_command(command)
      end

      fail CannotExecuteCommand unless response.is_a? Message::OK

      self
    end

    def create
      response = client.post build_create_message

      fail 'Could not create aggregate' unless response.is_a? Message::OK

      self
    end

    def query(query, create_on_unknown: true, ensure_consistency: true)
      response = send_query(query, ensure_consistency)

      if response.is_a?(Message::InvalidTarget) && create_on_unknown
        create
        response = send_query(query, ensure_consistency)
      end

      handle_query_response response
    end

    private

    def build_command_message(command)
      Message::Command.new(Aggro.local_node.id, id, command.to_details)
    end

    def build_create_message
      Message::CreateAggregate.new(Aggro.local_node.id, id, type)
    end

    def build_fast_query_message(query)
      Message::FastQuery.new(Aggro.local_node.id, id, query.to_details)
    end

    def build_query_message(query)
      Message::Query.new(Aggro.local_node.id, id, query.to_details)
    end

    def client
      locator.primary_node.client
    end

    def handle_query_response(message)
      fail CannotExecuteQuery unless message.is_a? Message::Result

      if message.result.is_a? Aggro::QueryError
        fail message.result.cause
      else
        message.result
      end
    end

    def locator
      @locator ||= Locator.new(id)
    end

    def send_command(command)
      client.post build_command_message(command)
    end

    def send_query(query, ensure_consistency)
      if ensure_consistency
        client.post build_query_message(query)
      else
        client.post build_fast_query_message(query)
      end
    end
  end
end
