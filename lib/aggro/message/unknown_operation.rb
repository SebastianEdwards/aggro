module Aggro
  module Message
    # Public: Unknown operation message.
    class UnknownOperation
      TYPE_CODE = '04'.freeze

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
