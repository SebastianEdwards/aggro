module Aggro
  # Public: Mixin to turn a PORO into an Aggro saga.
  module Saga
    extend ActiveSupport::Concern
    include AttributeDSL

    included do
      generate_id :causation_id
      generate_id :correlation_id
    end

    def saga_id
      @saga_id ||= SecureRandom.uuid
    end

    def start
      fail 'Saga is not valid' unless valid?

      promise = SagaPromise.new(self)
      response = Locator.new(saga_id).primary_node.client.post to_message

      if response.is_a? Message::OK
        promise
      else
        fail 'Saga could not be started'
      end
    end

    def to_details
      { name: model_name.name, args: serialized_attributes }
    end

    private

    def to_message
      Message::StartSaga.new Aggro.local_node.id, saga_id, to_details
    end

    class_methods do
      def initial(step_name = nil)
        step_name ? @initial = step_name : @initial
      end

      def step(step_name, &block)
        steps[step_name] = block
      end

      private

      def steps
        @steps ||= {}
      end
    end
  end
end
