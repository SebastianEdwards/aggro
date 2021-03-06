module Aggro
  module Message
    # Public: Start saga message.
    class StartSaga < Struct.new(:sender, :id, :details)
      TYPE_CODE = '13'.freeze

      def self.parse(string)
        new string[2..37], string[38..73], parse_details(string[74..-1])
      end

      def self.parse_details(details)
        Marshal.load details
      end

      def args
        details[:args]
      end

      def name
        details[:name]
      end

      def to_s
        "#{TYPE_CODE}#{sender}#{id}#{Marshal.dump details}"
      end
    end
  end
end
