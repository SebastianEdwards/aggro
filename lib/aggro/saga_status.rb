module Aggro
  # Public: Tracks the state of a saga as it processes.
  class SagaStatus
    include Projection
    include Concurrent::Obligation

    def initialize(id)
      @state = :unscheduled
      init_obligation
      super
    end

    events do
      def started
        self.state = :pending
      end

      def rejected(reason)
        set_state false, nil, reason
        event.set
      end

      def resolved(value)
        set_state true, value, nil
        event.set
      end
    end
  end
end
