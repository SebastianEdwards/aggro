require 'aggro/saga_runner/start_saga'

module Aggro
  # Private: Aggregate which runs saga processes.
  class SagaRunner
    include Aggregate

    allows StartSaga do |command|
      return unless state == :unstarted

      klass = ActiveSupport::Inflector.constantize command.name
      did.started state: klass.initial

      handler = klass.handler_for_step(state)
      @saga.send(:instance_exec, &handler)
    end

    def reject(reason)
      set_context

      did.rejected reason: reason

      @saga = nil
    end

    def resolve(value)
      set_context

      did.resolved value: value

      @saga = nil
    end

    def transition(step_name)
      set_context

      did.transitioned state: step_name

      handler = @klass.handler_for_step(step_name)
      @saga.send(:instance_exec, &handler)
    end

    events do
      def started(id, name, details, state)
        states << state
        @klass = ActiveSupport::Inflector.constantize name

        @details = details
        @saga = @klass.new(@details).tap do |saga|
          saga.instance_variable_set(:@saga_id, id)
          saga.instance_variable_set(:@runner, self)
        end

        set_context
      end

      def transitioned(state)
        states << state
      end

      def resolved
        states << :succeeded
      end

      def rejected
        states << :failed
      end
    end

    private

    def set_context
      @_context = @details

      Thread.current[:aggro_context] = {
        causation_id: @saga.causation_id,
        correlation_id: @saga.correlation_id
      }
    end

    def state
      states.last || :unstarted
    end

    def states
      @state ||= []
    end
  end
end
