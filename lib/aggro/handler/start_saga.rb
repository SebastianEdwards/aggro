module Aggro
  module Handler
    # Private: Handler for incoming command requests.
    class StartSaga < Struct.new(:message, :server)
      def call
        locator.local? ? handle_local : handle_foreign
      end

      private

      def create_channel
        channel = Channel.new message.id, 'SagaRunner'

        Aggro.channels[message.id] = channel
      end

      def create_saga
        Aggro.store.create message.id, 'SagaRunner'
      end

      def locator
        @locator ||= Locator.new(message.id)
      end

      def handle_foreign
        locator.primary_node.client.post message
      end

      def handle_known
        create_saga
        create_channel

        Aggro.channels[message.id].forward_command start_command

        Message::OK.new
      end

      def handle_local
        saga_known? ? handle_known : handle_unknown
      end

      def handle_unknown
        Message::SagaUnknown.new
      end

      def saga_known?
        ActiveSupport::Inflector.safe_constantize message.name
      end

      def start_command
        SagaRunner::StartSaga.new name: message.name, details: message.args,
                                  id: message.id
      end
    end
  end
end
