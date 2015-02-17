module Aggro
  class FileStore
    # Private: Serializes events to an IO object.
    class Writer
      def initialize(data_io, index_io)
        @data_io = data_io
        @index_io = index_io
      end

      def write(events)
        events.each do |event|
          @data_io.write EventSerializer.serialize(event)
          write_to_index @data_io.pos
        end

        @data_io.flush
        @index_io.flush
      end

      private

      def write_to_index(offset)
        @index_io.write Marshal.dump(offset)
      end
    end
  end
end
