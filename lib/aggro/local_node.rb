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

    def client
      @client ||= create_loopback_client
    end

    def endpoint
      "tcp://127.0.0.1:#{Aggro.port}"
    end

    def handle_command(message)
      command = message.to_command

      puts "Got #{message.name} for #{message.commandee_id}"

      if command.valid?
        puts 'Command is valid'
      else
        puts 'Command is invalid'
      end

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

    def create_loopback_client
      ->(msg) { message_router.route msg }.tap do |proc|
        proc.class_eval { alias_method :post, :call }
      end
    end

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
