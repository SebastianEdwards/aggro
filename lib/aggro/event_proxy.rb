module Aggro
  # Private: Used as a proxy to apply and save events to an aggregate.
  class EventProxy
    def initialize(aggregate, id)
      @aggregate = aggregate
      @id = id
    end

    def method_missing(method_sym, *args)
      details = merge_details_with_command_context(args.pop || {})
      event = Event.new(method_sym, Time.now.utc, details)

      Aggro.store.write_single @id, event
      Aggro.event_bus.publish @id, event
    end

    private

    def merge_details_with_command_context(details)
      @aggregate.instance_variable_get(:@_context).merge(details)
    end
  end
end
