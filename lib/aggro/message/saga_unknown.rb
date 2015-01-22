module Aggro
  module Message
    # Public: Saga unknown message.
    class SagaUnknown
      TYPE_CODE = '14'.freeze

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
