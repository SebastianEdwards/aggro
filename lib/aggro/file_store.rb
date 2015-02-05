require 'aggro/file_store/reader'
require 'aggro/file_store/writer'

module Aggro
  # Public: Stores and retrieves events by serializing them to flat files.
  class FileStore < AbstractStore
    INDEX_DIRECTORY = 'indexes'.freeze
    EVENT_DIRECTORY = 'events'.freeze
    REGISTRY_FILE = 'registry'.freeze

    def initialize(directory)
      @event_directory = [directory, EVENT_DIRECTORY].join('/')
      @index_directory = [directory, INDEX_DIRECTORY].join('/')

      FileUtils.mkdir_p @event_directory
      FileUtils.mkdir_p @index_directory

      @registry_file = [directory, REGISTRY_FILE].join('/')
      initialize_registry if File.exist? @registry_file
    end

    def all
      read registry.keys
    end

    def create(id, type)
      File.open(@registry_file, 'ab') do |registry_file|
        registry_file.write Marshal.dump [id, type]
        registry[id] = type
      end

      self
    end

    def exists?(id)
      registry[id] == true
    end

    def read(ids)
      ids.map { |id| id_to_event_stream id }
    end

    def registry
      @registry ||= {}
    end

    def write(event_streams)
      event_streams.each do |stream|
        FileStore::Writer.new(
          event_file(stream.id, 'ab'),
          index_file(stream.id, 'ab')
        ).write stream.events
      end

      self
    end

    def write_single(id, event)
      FileStore::Writer.new(
        event_file(id, 'ab'),
        index_file(id, 'ab')
      ).write [event]
    end

    private

    def event_file(id, flags = 'rb')
      File.new [@event_directory, id].join('/'), flags
    end

    def id_to_event_stream(id)
      EventStream.new id, type_for_id(id), id_to_reader(id).read
    rescue Errno::ENOENT
      EventStream.new id, type_for_id(id), []
    end

    def id_to_reader(id)
      FileStore::Reader.new event_file(id), index_file(id)
    end

    def index_file(id, flags = 'rb')
      File.new [@index_directory, id].join('/'), flags
    end

    def initialize_registry
      File.open(@registry_file) do |file|
        ObjectStream.new(file, type: 'marshal').each do |id, type|
          registry[id] = type
        end
      end
    end

    def type_for_id(id)
      registry[id]
    end
  end
end
