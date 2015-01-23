module Aggro
  # Public: Mixin to turn a PORO into an Aggro aggregate.
  module Aggregate
    extend ActiveSupport::Concern
    include EventDSL

    def initialize(id)
      @id = id

      @projections = self.class.projections.reduce({}) do |h, (name, klass)|
        class_eval { define_method(name) { @projections[name].project } }
        h.merge name => klass.new(id)
      end

      Aggro.event_bus.subscribe(id, self)
    end

    private

    def apply_command(command)
      return unless self.class.allows? command

      @_context = command.attributes

      handler = self.class.handler_for_command(command.class)
      instance_exec command, &handler
    ensure
      @_context = nil
    end

    def did
      fail 'Must be called within a command handler' unless @_context

      @event_caller ||= EventProxy.new(self, @id)
    end

    class_methods do
      def allows(command_class, &block)
        command_handlers[command_class] = block if block
      end

      def allows?(command)
        command_handlers.keys.include? command.class
      end

      def create(id = SecureRandom.uuid)
        find(id).create
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
