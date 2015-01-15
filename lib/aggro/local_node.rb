module Aggro
  # Public: Represents the local aggro server node.
  class LocalNode < Struct.new(:id)
    def bind
      return self if @server

      @server = Aggro.transport.server(endpoint) do |request|
        message_router.route MessageParser.parse(request)
      end

      @server.start

      self
    end

    def endpoint
      "tcp://127.0.0.1:#{Aggro.port}"
    end

    def handle_command(message)
      puts "Got command for #{message.commandee_id} from #{message.sender}"

      Message::OK.new
    end

    def handle_heartbeat(message)
      puts "Got heartbeat from #{message.sender}"

      Message::OK.new
    end

    def to_s
      id
    end

    private

    def message_router
      @message_router ||= begin
        MessageRouter.new.tap do |router|
          router.attach_handler Message::Command, method(:handle_command)
          router.attach_handler Message::Heartbeat, method(:handle_heartbeat)
        end
      end
    end
  end
end
