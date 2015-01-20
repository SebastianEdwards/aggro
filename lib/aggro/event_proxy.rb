module Aggro
  # Private: Used as a proxy to apply and save events to an aggregate.
  class EventProxy
    def initialize(aggregate, id)
      @aggregate = aggregate
      @id = id
    end

    def method_missing(method_sym, *args)
      return unless @aggregate.class.handles_event?(method_sym)

      details = ArgumentHashifier.hashify(parameters_for(method_sym), args)
      enriched = merge_details_with_command_context(details)

      event = Event.new(method_sym, Time.now, enriched)
      Aggro.store.write_single @id, event

      @aggregate.send :apply_event, event
    end

    private

    def merge_details_with_command_context(details)
      command_context = @aggregate.instance_variable_get(:@_context)

      command_context.merge(details) do |_, context, detail|
        detail ? detail : context
      end
    end

    def parameters_for(method_sym)
      @aggregate.method(method_sym).parameters
    end
  end
end
