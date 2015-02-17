module Aggro
  # Public: Mixin to turn a PORO into an Aggro aggregate.
  module Aggregate
    extend ActiveSupport::Concern
    include EventDSL
    include Logging

    def initialize(id)
      @id = id

      start_projections
      restore_from_event_stream

      log INFO, 'Restored to memory'
    end

    private

    def apply_command(command)
      return unless self.class.allows? command

      @_context = command.attributes

      handler = self.class.handler_for_command(command.class)
      instance_exec command, &handler
    rescue => e
      log ERROR, "Couldn't apply command\n#{e}\n#{e.backtrace.join "\n"}"

      raise e
    ensure
      @_context = nil
    end

    def did
      fail 'Must be called within a command handler' unless @_context

      @event_caller ||= EventProxy.new(self, @id)
    end

    def log(level, message, &block)
      super level, "#{self.class}/#{@id}", message, &block
    end

    def restore_from_event_stream
      Aggro.event_bus.subscribe(@id, self)
    rescue => e
      log FATAL, "Couldn't restore from events\n#{e}\n#{e.backtrace.join "\n"}"
    end

    def run_query(query)
      return unless self.class.responds_to? query

      handler = self.class.handler_for_query(query.class)
      instance_exec query, &handler
    rescue => e
      log ERROR, "Couldn't complete query\n#{e}\n#{e.backtrace.join "\n"}"
      QueryError.new(e)
    end

    def start_projections
      @projections = self.class.projections.reduce({}) do |h, (name, klass)|
        class_eval { define_method(name) { @projections[name] } }
        h.merge name => klass.new(@id)
      end
    rescue => e
      log FATAL, "Couldn't start projections\n#{e}\n#{e.backtrace.join "\n"}"
    end

    class_methods do
      def allows(command_class, &block)
        command_handlers[command_class] = block if block
      end

      def allows?(command)
        command_handlers.keys.include? command.class
      end

      def create(id = SecureRandom.uuid)
        fail ArgumentError unless id && id.length == 36

        find(id).create
      end

      def find(id)
        fail ArgumentError unless id && id.length == 36

        AggregateRef.new id, name
      end

      def handler_for_command(command_class)
        command_handlers[command_class]
      end

      def handler_for_query(query_class)
        query_handlers[query_class]
      end

      def projection(projection_name, via:)
        projections[projection_name] = via
      end

      def projections
        @projections ||= {}
      end

      def responds_to(query_class, &block)
        query_handlers[query_class] = block if block
      end

      def responds_to?(query)
        query_handlers.keys.include? query.class
      end

      private

      def command_handlers
        Aggro.command_handlers[name]
      end

      def query_handlers
        Aggro.query_handlers[name]
      end
    end
  end
end
