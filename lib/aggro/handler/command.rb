module Aggro
  module Handler
    # Private: Handler for incoming command requests.
    class Command < Struct.new(:message, :server)
      def call
        return handle_foreign unless commandee_local?

        command_known? ? handle_known : handle_unknown
      end

      private

      def command
        @command ||= message.to_command
      end

      def command_known?
        !command.nil?
      end

      def commandee_local?
        comandee_locator.local?
      end

      def comandee_locator
        @comandee_locator ||= Locator.new(message.commandee_id)
      end

      def handle_foreign
        Message::Ask.new comandee_locator.primary_node.id
      end

      def handle_known
        Message::OK.new
      end

      def handle_unknown
        Message::UnknownCommand.new
      end
    end
  end
end
