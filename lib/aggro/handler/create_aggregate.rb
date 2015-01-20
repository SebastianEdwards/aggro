module Aggro
  module Handler
    # Private: Handler for incoming command requests.
    class CreateAggregate < Struct.new(:message, :server)
      def call
        local? ? handle_local : handle_foreign
      end

      private

      def add_to_channels
        channel = AggregateChannel.new(Aggro.store.read([message.id]).first)
        Aggro.channels[message.id] = channel
      end

      def exists_in_channels?
        Aggro.channels.keys.include?(message.id)
      end

      def handle_local
        Aggro.store.create message.id, message.type

        add_to_channels unless exists_in_channels?

        Message::OK.new
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
