module Aggro
  module Handler
    # Private: Handler for incoming command requests.
    class GetEvents < Struct.new(:message, :server)
      def call
        local? ? handle_local : handle_foreign
      end

      private

      def handle_local
        events = Aggro.store.read([message.id]).first.events

        Message::Events.new(message.id, events.to_a)
      end

      def handle_foreign
        Message::Ask.new locator.primary_node.id
      end

      def local?
        locator.local?
      end

      def locator
        @locator ||= Locator.new(message.id)
      end
    end
  end
end
