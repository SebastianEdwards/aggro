module Aggro
  module Handler
    # Private: Handler for incoming command requests.
    class StartSaga < Struct.new(:message, :server)
      def call
        locator.local? ? handle_local : handle_foreign
      end

      private

      def create_channel
        channel = Channel.new saga.saga_id, saga.class.name

        Aggro.channels[saga.saga_id] = channel
      end

      def create_saga
        Aggro.store.create saga.saga_id, saga.class.name
      end

      def locator
        @locator ||= Locator.new(message.id)
      end

      def handle_foreign
        locator.primary_node.client.post message
      end

      def handle_known
        create_saga
        create_channel.forward_command :start

        Message::OK.new
      end

      def handle_local
        saga_known? ? handle_known : handle_unknown
      end

      def handle_unknown
        Message::SagaUnknown.new
      end

      def saga
        @saga ||= message.to_saga
      end

      def saga_known?
        !saga.nil?
      end
    end
  end
end
