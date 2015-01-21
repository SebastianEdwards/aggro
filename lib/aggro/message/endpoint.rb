module Aggro
  module Message
    # Public: Endpoint message.
    class Endpoint < Struct.new(:endpoint)
      TYPE_CODE = '12'.freeze

      def self.parse(string)
        new string[2..-1]
      end

      def to_s
        "#{TYPE_CODE}#{endpoint}"
      end
    end
  end
end
