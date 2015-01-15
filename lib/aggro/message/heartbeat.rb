module Aggro
  module Message
    # Public: Heartbeat message.
    class Heartbeat < Struct.new(:sender)
      TYPE_CODE = '02'.freeze

      def self.parse(string)
        new string[2..37]
      end

      def to_s
        "#{TYPE_CODE}#{sender}"
      end
    end
  end
end
