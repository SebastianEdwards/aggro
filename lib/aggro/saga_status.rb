module Aggro
  # Public: Tracks the state of a saga as it processes.
  class SagaStatus
    attr_reader :reason
    attr_reader :value

    def completed?
      %i(failed succeeded).include? state
    end

    def fulfilled?
      state == :succeeded
    end

    def rejected?
      state == :failed
    end

    def state
      states.peek || saga_class.initial
    end

    def wait(timeout = nil)
      puts timeout
    end

    private

    include Projection

    events do
      def started(step_name)
        states << step_name
      end

      def transitioned(step_name)
        states << step_name
      end

      def failed(reason)
        states << :failed
        @reason = reason
        @on_reject.call reason if @on_reject
      end

      def succeeded(response)
        states << :succeeded
        @value = value
        @on_fulfill.call response if @on_fulfill
      end
    end

    def states
      @states ||= []
    end
  end
end
