module Aggro
  module Message
    # Public: Publisher endpoint inquiry message.
    class PublisherEndpointInquiry < Struct.new(:sender)
      TYPE_CODE = '11'.freeze

      def self.parse(string)
        new string[2..37]
      end

      def to_s
        "#{TYPE_CODE}#{sender}"
      end
    end
  end
end
