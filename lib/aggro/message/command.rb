module Aggro
  module Message
    # Public: Command message.
    class Command < Struct.new(:sender, :commandee_id, :details)
      TYPE_CODE = '03'.freeze

      def self.parse(string)
        new string[2..37], string[38..73], parse_details(string[74..-1])
      end

      def self.parse_details(details)
        MessagePack.unpack details
      end

      def to_s
        "#{TYPE_CODE}#{sender}#{commandee_id}#{MessagePack.pack details}"
      end
    end
  end
end
