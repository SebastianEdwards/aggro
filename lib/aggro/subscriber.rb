module Aggro
  # Public: Subscribes to topics at a given endpoint.
  class Subscriber
    RAW_HANDLER = :handle_raw

    def initialize(endpoint, callable = nil, &block)
      if callable
        @callback = callable
      elsif block_given?
        @callback = block
      else
        fail ArgumentError
      end

      @transport_sub = Aggro.transport.subscriber endpoint, method(RAW_HANDLER)
      @subscribed_topics = Set.new
    end

    def bind
      @transport_sub.start
    end

    def handle_message(message)
      @callback.call message.id, message.events if message.is_a? Message::Events
    end

    def stop
      @transport_sub.stop
    end

    def subscribe_to_topic(topic)
      return if @subscribed_topics.include? topic

      @subscribed_topics << topic
      @transport_sub.add_subscription message_prefix_for_topic(topic)
    end

    private

    def handle_raw(raw)
      handle_message MessageParser.parse raw
    end

    def message_prefix_for_topic(topic)
      Message::Events::TYPE_CODE + topic
    end
  end
end
