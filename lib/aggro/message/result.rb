module Aggro
  module Message
    # Public: Result message.
    class Result < Struct.new(:result)
      TYPE_CODE = '14'.freeze

      def self.parse(string)
        new Marshal.load(string[2..-1])
      end

      def to_s
        "#{TYPE_CODE}#{Marshal.dump result}"
      end
    end
  end
end
