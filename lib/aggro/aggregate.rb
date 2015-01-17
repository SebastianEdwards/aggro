module Aggro
  # Public: Mixin to turn a PORO into an Aggro aggregate.
  module Aggregate
    extend ActiveSupport::Concern

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

      private

      def command_handlers
        @command_handlers ||= {}
      end
    end
  end
end
