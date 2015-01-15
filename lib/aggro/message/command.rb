module Aggro
  module Message
    # Public: Command message.
    class Command < Struct.new(:sender, :commandee_id, :details)
      TYPE_CODE = '03'.freeze

      def self.parse(string)
        new string[2..37], string[38..73], parse_details(string[74..-1])
      end

      def self.parse_details(details)
        MessagePack.unpack(details).deep_symbolize_keys!
      end

      def args
        details[:args]
      end

      def command_class
        ActiveSupport::Inflector.safe_constantize name
      end

      def name
        details[:name]
      end

      def to_command
        command_class.new args if command_class
      end

      def to_s
        "#{TYPE_CODE}#{sender}#{commandee_id}#{MessagePack.pack details}"
      end
    end
  end
end
