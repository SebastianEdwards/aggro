module Aggro
  # Private: Handles invoking events on a subscriber object.
  class Subscription
    attr_reader :caught_up

    def initialize(topic, subscriber, namespace, filters, at_version)
      @topic = topic
      @subscriber = subscriber
      @namespace = namespace
      @filters = filters
      @at_version = at_version
      @canceled = false
    end

    def cancel
      Aggro.event_bus.unsubscribe @topic, self unless @canceled
      @canceled = true
    end

    def handle_event(event)
      return if @canceled

      invoke(event) if handles_event?(event) && matches_filter?(event)
    end

    def notify_subscription_caught_up
      @caught_up = true

      return unless @subscriber.handles_event? :caught_up, @namespace

      @subscriber.send "#{@namespace}_caught_up"
    end

    private

    def handles_event?(event)
      @subscriber.handles_event? event.name, @namespace
    end

    def invoke(event)
      Invokr.invoke method: "#{@namespace}_#{event.name}",
                    using: event.details, on: @subscriber
    end

    def matches_filter?(event)
      @filters.all? do |filter_key, filter_value|
        event.details[filter_key] == filter_value
      end
    end
  end
end
