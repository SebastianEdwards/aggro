module Aggro
  # Public: Tracks the state of a saga as it processes.
  class SagaStatus
    include Projection

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

    events do
      def started(state)
        puts 'status started'
        states << state.to_sym
      end

      def transitioned(state)
        puts 'status transitioned'
        states << state.to_sym
      end

      def rejected(reason)
        states << :failed
        @reason = reason
        @on_reject.call reason if @on_reject
      end

      def resolved(value)
        states << :succeeded
        @value = value
        @on_fulfill.call value if @on_fulfill
      end
    end

    private

    def states
      @states ||= []
    end
  end
end
