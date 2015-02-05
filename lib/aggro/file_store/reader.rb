module Aggro
  class FileStore < AbstractStore
    # Private: Deserialized events from an IO object.
    class Reader
      def initialize(data_io, index_io)
        @data_io = data_io
        @index_io = index_io
      end

      def read
        ObjectStream.new(@data_io, type: 'marshal')
      end

      private

      def index
        @index ||= ObjectStream.new(@index_io, type: 'marshal')
      end
    end
  end
end
