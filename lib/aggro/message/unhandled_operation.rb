module Aggro
  module Message
    # Public: Unhandled operation message.
    class UnhandledOperation
      TYPE_CODE = '07'.freeze

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
