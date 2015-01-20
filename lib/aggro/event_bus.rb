module Aggro
  # Public: Publishes events to any subscribed listeners.
  class EventBus
    Subscription = Struct.new(:subscriber, :namespace, :at_version)

    def publish(topic, event)
      subscriptions[topic].each do |subscription|
        invoke subscription, event
      end
    end

    def subscribe(subscriber, topic, event_namespace = nil)
      subscription = Subscription.new(subscriber, event_namespace, 0)

      catchup_subscriber(subscription, topic)

      subscriptions[topic] ||= []
      subscriptions[topic] << subscription
    end

    private

    def catchup_subscriber(subscription, topic)
      message = Message::GetEvents.new(Aggro.local_node.id, topic, 0)
      response = Locator.new(topic).primary_node.client.post message

      if response.is_a? Message::Events
        response.events.each { |event| invoke(subscription, event) }
      else
        fail 'Could not catchup subscriber'
      end
    end

    def invoke(subscription, event)
      return unless subscription.subscriber.handles_event? event.name

      Invokr.invoke method: event.name, using: event.details,
                    on: subscription.subscriber
    end

    def subscriptions
      @subscriptions ||= {}
    end
  end
end
