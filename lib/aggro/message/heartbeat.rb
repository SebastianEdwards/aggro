module Aggro
  module Message
    # Public: Heartbeat message.
    class Heartbeat < Struct.new(:sender)
      def self.parse(string)
        new string[1..36]
      end
    end
  end
end
