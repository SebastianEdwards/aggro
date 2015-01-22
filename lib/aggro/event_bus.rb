module Aggro
  # Public: Publishes events to any subscribed listeners.
  class EventBus
    Subscription = Struct.new(:subscriber, :namespace, :at_version)

    def initialize
      @remote_publishers = {}
    end

    def publish(topic, event)
      Aggro.server.publish Message::Events.new(topic, [event])

      return unless subscriptions.key? topic

      subscriptions[topic].each do |subscription|
        invoke subscription, event
      end
    end

    def subscribe(topic, subscriber, event_namespace = nil)
      subscription = Subscription.new(subscriber, event_namespace, 0)

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
        response.events.each { |event| invoke(subscription, event) }
      else
        fail 'Could not catchup subscriber'
      end
    end

    def invoke(subscription, event)
      return unless subscription_handles_event?(subscription, event.name)

      Invokr.invoke method: "#{subscription.namespace}_#{event.name}",
                    using: event.details, on: subscription.subscriber
    end

    def handle_events(topic, events)
      subscriptions[topic].each do |subscription|
        events.each { |event| invoke subscription, event }
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

    def subscription_handles_event?(subscription, event_name)
      subscription.subscriber.handles_event? event_name, subscription.namespace
    end

    def subscriptions
      @subscriptions ||= {}
    end
  end
end
