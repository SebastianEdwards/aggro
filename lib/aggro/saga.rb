module Aggro
  # Public: Mixin to turn a PORO into an Aggro saga.
  module Saga
    extend ActiveSupport::Concern

    include AttributeDSL
    include BindingDSL
    include EventDSL

    included do
      generate_id :causation_id
      generate_id :correlation_id
    end

    def bindings
      @runner.bindings
    end

    def default_filters
      { correlation_id: correlation_id }
    end

    def saga_id
      @saga_id ||= SecureRandom.uuid
    end

    def start
      fail 'Saga is not valid' unless valid?

      promise = SagaStatus.new(saga_id)

      message = Message::StartSaga.new Aggro.local_node.id, saga_id, to_details
      response = primary_node.client.post message

      if response.is_a? Message::OK
        promise
      else
        fail 'Saga could not be started'
      end
    end

    private

    def primary_node
      @primary_node ||= Locator.new(saga_id).primary_node
    end

    def to_details
      { name: model_name.name, args: serialized_attributes }
    end

    def reject(reason = nil)
      fail 'Runner not set' unless @runner

      @runner.reject reason
    end

    def resolve(value = nil)
      fail 'Runner not set' unless @runner

      @runner.resolve value
    end

    def transition(step_name, *args)
      fail 'Runner not set' unless @runner

      @runner.transition step_name, *args
    end

    class_methods do
      def handler_for_step(step_name)
        steps[step_name]
      end

      def handles_step?(step_name)
        steps.key? step_name
      end

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
