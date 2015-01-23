module Aggro
  class SagaRunner
    # Private: Command to start a SagaRunner.
    class StartSaga
      include Command

      id :id
      string :name
      attribute :details
    end
  end
end
