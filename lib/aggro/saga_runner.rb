require 'aggro/saga_runner/start_saga'

module Aggro
  # Private: Aggregate which runs saga processes.
  class SagaRunner
    include Aggregate

    allows StartSaga do |command|
      @details = command.details

      @klass = ActiveSupport::Inflector.constantize command.name

      @saga = @klass.new(@details).tap do |saga|
        saga.instance_variable_set(:@saga_id, command.id)
        saga.instance_variable_set(:@runner, self)
      end

      did.started state: @klass.initial

      run_step @klass.initial
    end

    def bindings
      @bindings ||= []
    end

    def cancel_bindings
      bindings.each(&:cancel)
      @bindings = []
    end

    def reject(reason)
      did.rejected reason: reason

      teardown
    end

    def resolve(value)
      did.resolved value: value

      teardown
    end

    def transition(step_name)
      cancel_bindings
      did.transitioned state: step_name

      run_step step_name
    end

    private

    def did
      @_context = @details
      super
    end

    def run_step(step_name)
      with_thread_ids do
        handler = @klass.handler_for_step(step_name)
        @saga.send(:instance_exec, &handler)
      end
    end

    def teardown
      @saga = nil
      cancel_bindings
      Aggro.event_bus.subscribe(@id, self)
    end

    def with_thread_ids
      old_causation_id = Thread.current[:causation_id]
      old_correlation_id = Thread.current[:correlation_id]
      Thread.current[:causation_id] = @details[:causation_id]
      Thread.current[:correlation_id] = @details[:correlation_id]
      yield
    ensure
      Thread.current[:causation_id] = old_causation_id
      Thread.current[:correlation_id] = old_correlation_id
    end
  end
end
