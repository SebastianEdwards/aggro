module Aggro
  module Handler
    # Private: Handler for incoming command requests.
    class Command < Struct.new(:message, :server)
      def call
        command_known? ? handle_known : handle_unknown
      end

      private

      def command
        @command ||= message.to_command
      end

      def command_known?
        !command.nil?
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
