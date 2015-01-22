module Aggro
  # Public: Tracks the state of a saga as it processes.
  class SagaPromise
    include Projection

    attr_reader :saga

    attr_reader :reason
    attr_reader :value

    def initialize(saga)
      super saga.saga_id

      @saga = saga
    end

    def fulfilled?
      %w(failed succeeded).include? state
    end

    def state
      states.peek || saga_class.initial
    end

    events do
      def transitioned(new_state)
        states << new_state
      end

      def failed(reason)
        states << :rejected
        @reason = reason
        @on_reject.call reason if @on_reject
      end

      def succeeded(response)
        states << :fulfilled
        @value = value
        @on_fulfill.call response if @on_fulfill
      end
    end

    private

    def saga_class
      @saga_class ||= saga.class
    end

    def states
      @states ||= []
    end
  end
end
