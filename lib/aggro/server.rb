module Aggro
  # Public: Binds a transport endpoint and handles incoming messages.
  class Server
    def initialize(endpoint)
      @transport_server = Aggro.transport.server endpoint, method(:handle_raw)
    end

    def bind
      @transport_server.start
    end

    def handle_message(message)
      message_router.route message
    end

    def stop
      @transport_server.stop
    end

    private

    def handle_command(message)
      Handler::Command.new(message, self).call
    end

    def handle_heartbeat(message)
      puts "Got heartbeat from #{message.sender}"

      Message::OK.new
    end

    def handle_raw(raw)
      handle_message MessageParser.parse raw
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
