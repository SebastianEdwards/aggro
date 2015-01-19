module Aggro
  # Public: Mixin to turn a PORO into an Aggro aggregate.
  module Aggregate
    extend ActiveSupport::Concern

    def initialize(id, _events)
      @id = id
    end

    def apply_command(command)
      return unless self.class.allows? command.class

      handler = self.class.handler_for_command(command.class)
      instance_exec command, &handler
    end

    # Public: Adds class interface to aggregate.
    module ClassMethods
      def allows(command_class, &block)
        command_handlers[command_class] = block if block
      end

      def allows?(command_class)
        command_handlers.keys.include? command_class
      end

      def find(id)
        AggregateRef.new id, name
      end

      def handler_for_command(command_class)
        command_handlers[command_class]
      end

      private

      def command_handlers
        @command_handlers ||= {}
      end
    end
  end
end
