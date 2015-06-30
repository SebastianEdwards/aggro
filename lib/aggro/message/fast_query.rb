module Aggro
  module Message
    # Public: Query message.
    class FastQuery < Struct.new(:sender, :queryable_id, :details)
      TYPE_CODE = '16'.freeze

      def self.parse(string)
        new string[2..37], string[38..73], parse_details(string[74..-1])
      end

      def self.parse_details(details)
        Marshal.load details
      end

      def args
        details[:args]
      end

      def name
        details[:name]
      end

      def query_class
        ActiveSupport::Inflector.safe_constantize name
      end

      def to_query
        query_class.new args if query_class
      end

      def to_s
        "#{TYPE_CODE}#{sender}#{queryable_id}#{Marshal.dump details}"
      end
    end
  end
end
