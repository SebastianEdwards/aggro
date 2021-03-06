module Aggro
  # Public: Publishes events to any subscribed listeners.
  class EventBus
    attr_reader :remote_publishers

    def initialize
      @remote_publishers = {}
    end

    def publish(topic, event)
      Aggro.server.publish Message::Events.new(topic, [event])

      return unless subscriptions.key? topic

      subscriptions[topic].each do |subscription|
        sleep 0.01 until subscription.caught_up
        subscription.handle_event event
      end
    end

    def subscribe(topic, subscriber, event_namespace = nil, filters = {})
      subscription = Subscription.new(topic, subscriber, event_namespace,
                                      filters, 0)

      catchup_subscriber topic, subscription

      subscriptions[topic] ||= []
      subscriptions[topic] << subscription

      subscribe_bus_to_publisher topic

      subscription
    end

    def unsubscribe(topic, subscriber)
      subscriptions[topic].delete subscriber
    end

    def shutdown
      remote_publishers.values.each(&:stop)
    end

    private

    def catchup_local(topic, subscription)
      Aggro.store.read([topic]).first.events.each do |event|
        subscription.handle_event event
      end
    end

    def catchup_remote(topic, subscription, node)
      message = Message::GetEvents.new(Aggro.local_node.id, topic, 0)
      response = node.client.post message

      if response.is_a? Message::Events
        response.events.each { |event| subscription.handle_event event }
      else
        fail 'Could not catchup subscriber'
      end
    end

    def catchup_subscriber(topic, subscription)
      node = Locator.new(topic).primary_node

      if node.is_a? LocalNode
        catchup_local(topic, subscription)
      else
        catchup_remote(topic, subscription, node)
      end

      subscription.notify_subscription_caught_up
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
