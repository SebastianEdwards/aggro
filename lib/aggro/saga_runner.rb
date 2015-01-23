require 'aggro/saga_runner/start_saga'

module Aggro
  # Private: Aggregate which runs saga processes.
  class SagaRunner
    include Aggregate

    allows StartSaga do
      did.started

      handler = @klass.handler_for_step(@klass.initial)
      @saga.send(:instance_exec, &handler)
    end

    events do
      def started(id, name, details)
        @klass = ActiveSupport::Inflector.constantize name
        @saga = @klass.new(details).tap do |saga|
          saga.instance_variable_set(:@saga_id, id)
          saga.instance_variable_set(:@runner, self)
        end
      end

      def transitioned
      end

      def resolved
      end

      def rejected
      end
    end
  end
end
