module Aggro
  module Message
    # Public: Ask message.
    class Ask < Struct.new(:node_id)
      TYPE_CODE = '05'.freeze

      def self.parse(string)
        new string[2..37]
      end

      def to_s
        "#{TYPE_CODE}#{node_id}"
      end
    end
  end
end
