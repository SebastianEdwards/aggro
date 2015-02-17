module Aggro
  class FileStore
    # Private: Deserialized events from an IO object.
    class Reader
      def initialize(data_io, index_io)
        @data_io = data_io
        @index_io = index_io
      end

      def read
        MarshalStream.new @data_io
      end

      private

      def index
        @index ||= MarshalStream.new(@index_io)
      end
    end
  end
end
