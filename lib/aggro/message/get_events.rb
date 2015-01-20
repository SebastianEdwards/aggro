module Aggro
  module Message
    # Public: Get events message.
    class GetEvents < Struct.new(:sender, :id, :from_version)
      TYPE_CODE = '09'.freeze

      def self.parse(string)
        new string[2..37], string[38..73], string[74..-1].to_i
      end

      def to_s
        "#{TYPE_CODE}#{sender}#{id}#{from_version || 0}"
      end
    end
  end
end
