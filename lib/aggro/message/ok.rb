module Aggro
  module Message
    # Public: Heartbeat message.
    class OK
      TYPE_CODE = '01'.freeze

      def self.parse(_string)
        new
      end

      def self.new
        @singleton ||= super
      end

      def to_s
        "#{TYPE_CODE}"
      end
    end
  end
end
