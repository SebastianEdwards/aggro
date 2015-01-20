module Aggro
  # Public: Mixin to turn a PORO into an Aggro aggregate.
  module Aggregate
    extend ActiveSupport::Concern
    include EventDSL

    def initialize(id, events)
      @id = id
      events.each { |event| apply_event event }
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
      evented.each do |target|
        if target.handles_event? event.name
          Invokr.invoke method: event.name, using: event.details, on: target
        end
      end
    end

    def did
      @event_caller ||= EventProxy.new(self, @id)
    end

    def evented
      @evented ||= [self, projections.values].flatten
    end

    def projections
      @projections ||= self.class.projections.reduce({}) do |h, (name, klass)|
        class_eval do
          define_method(name) do
            @projections[name].project
          end
        end
        h.merge name => klass.new
      end
    end

    class_methods do
      def allows(command_class, &block)
        command_handlers[command_class] = block if block
      end

      def allows?(command_class)
        command_handlers.keys.include? command_class
      end

      def create(id = SecureRandom.uuid)
        message = Message::CreateAggregate.new(Aggro.local_node.id, id, name)
        result = Locator.new(id).primary_node.client.post(message)

        if result.is_a? Message::OK
          id
        else
          fail 'Could not create aggregate'
        end
      end

      def find(id)
        AggregateRef.new id, name
      end

      def handler_for_command(command_class)
        command_handlers[command_class]
      end

      def projection(projection_name, via:)
        projections[projection_name] = via
      end

      def projections
        @projections ||= {}
      end

      private

      def command_handlers
        @command_handlers ||= {}
      end
    end
  end
end
