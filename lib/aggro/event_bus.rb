module Aggro
  # Public: Publishes events to any subscribed listeners.
  class EventBus
    def initialize
      @remote_publishers = {}
    end

    def publish(topic, event)
      Aggro.server.publish Message::Events.new(topic, [event])

      return unless subscriptions.key? topic

      subscriptions[topic].each do |subscription|
        subscription.handle_event event
      end
    end

    def subscribe(topic, subscriber, event_namespace = nil, filters = {})
      subscription = Subscription.new(subscriber, event_namespace, filters, 0)

      catchup_subscriber topic, subscription

      subscriptions[topic] ||= []
      subscriptions[topic] << subscription

      subscribe_bus_to_publisher topic
    end

    private

    attr_reader :remote_publishers

    def catchup_subscriber(topic, subscription)
      message = Message::GetEvents.new(Aggro.local_node.id, topic, 0)
      response = Locator.new(topic).primary_node.client.post message

      if response.is_a? Message::Events
        response.events.each { |event| subscription.handle_event event }
      else
        fail 'Could not catchup subscriber'
      end
    end

    def handle_events(topic, events)
      subscriptions[topic].each do |subscription|
        events.each { |event| subscription.handle_event event }
      end
    end

    def subscribe_bus_to_publisher(topic)
      node = Locator.new(topic).primary_node

      return if node.is_a? LocalNode

      publisher_endpoint = node.publisher_endpoint
      remote_publishers[publisher_endpoint] ||= begin
        Subscriber.new(publisher_endpoint, method(:handle_events)).tap(&:bind)
      end

      remote_publishers[publisher_endpoint].subscribe_to_topic topic
    end

    def subscriptions
      @subscriptions ||= {}
    end
  end
end
