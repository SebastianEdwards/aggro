module Aggro
  module Handler
    # Private: Handler for incoming command requests.
    class Command < Struct.new(:message, :server)
      def call
        commandee_local? ? handle_local : handle_foreign
      end

      private

      def channel
        Aggro.channels[commandee_id]
      end

      def command
        @command ||= message.to_command
      end

      def commandee_id
        message.commandee_id
      end

      def command_known?
        !command.nil?
      end

      def commandee_local?
        comandee_locator.local?
      end

      def comandee_locator
        @comandee_locator ||= Locator.new(commandee_id)
      end

      def handle_foreign
        comandee_locator.primary_node.client.post message
      end

      def handle_known
        if channel.handles_command?(command)
          channel.forward_command command

          Message::OK.new
        else
          Message::UnhandledOperation.new
        end
      rescue NoMethodError
        Message::InvalidTarget.new
      end

      def handle_local
        command_known? ? handle_known : handle_unknown
      end

      def handle_unknown
        Message::UnknownOperation.new
      end
    end
  end
end
