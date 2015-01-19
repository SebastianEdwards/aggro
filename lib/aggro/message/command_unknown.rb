module Aggro
  module Message
    # Public: Command unknown message.
    class CommandUnknown
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
