module Aggro
  # Public: Mixin to turn a PORO into an Aggro aggregate.
  module Aggregate
    extend ActiveSupport::Concern

    # Private: Used as a proxy to apply and save events to an aggregate.
    class EventCaller
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

    def initialize(id, events)
      @id = id

      events.each do |event|
        apply_event event
      end
    end

    def apply_command(command)
      return unless self.class.allows? command.class

      @_context = command.to_details[:args]

      handler = self.class.handler_for_command(command.class)
      instance_exec command, &handler
    ensure
      @_context = nil
    end

    private

    def apply_event(event)
      Invokr.invoke method: event.name, on: self, using: event.details
    end

    def did
      @event_caller ||= EventCaller.new(self, @id)
    end

    # Public: Adds class interface to aggregate.
    module ClassMethods
      def allows(command_class, &block)
        command_handlers[command_class] = block if block
      end

      def allows?(command_class)
        command_handlers.keys.include? command_class
      end

      def events(&block)
        test_class = Class.new(BasicObject)
        starting_methods = test_class.instance_methods
        test_class.class_eval(&block)

        test_class.instance_methods.each do |method|
          event_methods << method unless starting_methods.include? method
        end

        class_eval(&block)
      end

      def find(id)
        AggregateRef.new id, name
      end

      def handles_event?(event_name)
        event_methods.include? event_name
      end

      def handler_for_command(command_class)
        command_handlers[command_class]
      end

      private

      def command_handlers
        @command_handlers ||= {}
      end

      def event_methods
        @event_methods ||= []
      end
    end
  end
end
