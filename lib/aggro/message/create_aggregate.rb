module Aggro
  module Message
    # Public: Create aggregate message.
    class CreateAggregate < Struct.new(:sender, :id, :type)
      TYPE_CODE = '08'.freeze

      def self.parse(string)
        new string[2..37], string[38..73], string[74..-1]
      end

      def to_s
        "#{TYPE_CODE}#{sender}#{id}#{type}"
      end
    end
  end
end
