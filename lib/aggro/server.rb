module Aggro
  # Public: Binds a transport endpoint and handles incoming messages.
  class Server
    RAW_HANDLER = :handle_raw

    HANDLERS = {
      Message::Command                  => :handle_command,
      Message::CreateAggregate          => :handle_create,
      Message::FastQuery                => :handle_fast_query,
      Message::GetEvents                => :handle_get_events,
      Message::Heartbeat                => :handle_heartbeat,
      Message::PublisherEndpointInquiry => :handle_publisher_endpoint_inquiry,
      Message::Query                    => :handle_query,
      Message::StartSaga                => :handle_start_saga
    }

    def initialize(endpoint, publisher_endpoint)
      @endpoint = endpoint
      @publisher_endpoint = publisher_endpoint

      @transport_server = Aggro.transport.server endpoint, method(RAW_HANDLER)
      @transport_publisher = Aggro.transport.publisher publisher_endpoint

      @publish_mutex = Mutex.new
    end

    def bind
      @transport_server.start
    end

    def handle_message(message)
      message_router.route message
    end

    def publish(message)
      @publish_mutex.synchronize do
        @transport_publisher.publish message
      end
    end

    def stop
      @transport_publisher.close_socket
      @transport_server.stop
    end

    private

    def handle_command(message)
      Handler::Command.new(message, self).call
    end

    def handle_create(message)
      Handler::CreateAggregate.new(message, self).call
    end

    def handle_fast_query(message)
      Handler::FastQuery.new(message, self).call
    end

    def handle_get_events(message)
      Handler::GetEvents.new(message, self).call
    end

    def handle_heartbeat(_message)
      Message::OK.new
    end

    def handle_publisher_endpoint_inquiry(_message)
      Message::Endpoint.new @publisher_endpoint
    end

    def handle_query(message)
      Handler::Query.new(message, self).call
    end

    def handle_raw(raw)
      handle_message MessageParser.parse raw
    end

    def handle_start_saga(message)
      Handler::StartSaga.new(message, self).call
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
