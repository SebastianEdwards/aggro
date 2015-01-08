require 'aggro/flat_file_store/reader'
require 'aggro/flat_file_store/writer'

module Aggro
  # Public: Stores and retrieves events by serializing them to flat files.
  class FlatFileStore < AbstractStore
    INDEX_DIRECTORY = 'indexes'.freeze

    class << self
      attr_accessor :directory
    end

    def read(refs)
      refs.map { |ref| ref_to_event_stream ref }
    end

    def write(event_streams)
      event_streams.each do |stream|
        FlatFileStore::Writer.new(data_file(stream, 'ab'),
                                  index_file(stream, 'ab')).write stream.events
      end
    end

    private

    def data_file(ref, flags = 'rb')
      dir = [FlatFileStore.directory, ref.type].join('/')
      FileUtils.mkdir_p dir

      File.new [dir, ref.id].join('/'), flags
    end

    def index
      @index ||= begin
        MessagePack.unpack @index_io.read
      end
    end

    def index_file(ref, flags = 'rb')
      dir = [FlatFileStore.directory, INDEX_DIRECTORY].join('/')
      FileUtils.mkdir_p dir

      File.new [dir, ref.id].join('/'), flags
    end

    def ref_to_event_stream(ref)
      EventStream.new ref.id, ref.type, ref_to_reader(ref).read
    rescue Errno::ENOENT
      EventStream.new ref.id, ref.type, []
    end

    def ref_to_reader(ref)
      FlatFileStore::Reader.new data_file(ref), index_file(ref)
    end
  end
end
