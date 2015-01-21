module Aggro
  # Public: Binds a transport endpoint and handles incoming messages.
  class Server
    RAW_HANDLER = :handle_raw

    HANDLERS = {
      Message::Command                  => :handle_command,
      Message::CreateAggregate          => :handle_create,
      Message::GetEvents                => :handle_get_events,
      Message::Heartbeat                => :handle_heartbeat,
      Message::PublisherEndpointInquiry => :handle_publisher_endpoint_inquiry
    }

    def initialize(endpoint)
      @transport_server = Aggro.transport.server endpoint, method(RAW_HANDLER)
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

    def handle_create(message)
      Handler::CreateAggregate.new(message, self).call
    end

    def handle_get_events(message)
      Handler::GetEvents.new(message, self).call
    end

    def handle_heartbeat(_message)
      Message::OK.new
    end

    def handle_publisher_endpoint_inquiry(_message)
      Message::Endpoint.new Aggro.local_node.publisher_endpoint
    end

    def handle_raw(raw)
      handle_message MessageParser.parse raw
    end

    def message_router
      @message_router ||= begin
        MessageRouter.new.tap do |router|
          HANDLERS.each { |type, sym| router.attach_handler type, method(sym) }
        end
      end
    end
  end
end
