module Aggro
  module Message
    # Public: Get events message.
    class Events < Struct.new(:id, :events)
      TYPE_CODE = '09'.freeze

      def self.parse(string)
        new string[2..37], parse_events(string[38..-1])
      end

      def self.parse_events(string)
        MessagePack::Unpacker.new(StringIO.new(string)).each.map do |hash|
          EventSerializer.event_from_hash(hash)
        end
      end

      def serialize_events
        events.map { |event| EventSerializer.serialize event }.join
      end

      def to_s
        "#{TYPE_CODE}#{id}#{serialize_events}"
      end
    end
  end
end
