module Aggro
  module Message
    # Public: OK message.
    class ServerError
      TYPE_CODE = '00'.freeze

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
