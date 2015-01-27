module Aggro
  class FileStore < AbstractStore
    # Private: Deserialized events from an IO object.
    class Reader
      def initialize(data_io, index_io)
        @data_io = data_io
        @index_io = index_io
      end

      def read
        Enumerator.new do |yielder|
          MessagePack::Unpacker.new(@data_io, symbolize_keys: true).each do |h|
            yielder << EventSerializer.event_from_hash(h)
          end
        end
      end

      private

      def index
        @index ||= MessagePack::Unpacker.new(@index_io).each.to_a
      end
    end
  end
end
