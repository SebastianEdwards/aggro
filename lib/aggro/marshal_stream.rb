# Private: Wrapper around an IO object to read/write Marshaled objects.
class MarshalStream
  include Enumerable

  DEFAULT_MAX_OUTBOX = 10

  class StreamError < StandardError; end

  attr_reader :io
  attr_reader :max_outbox

  def initialize(io, max_outbox: DEFAULT_MAX_OUTBOX)
    @io = io
    @max_outbox = max_outbox
    @inbox = []
    @outbox = []
  end

  def close
    flush_outbox
    io.close
  end

  def closed?
    io.closed?
  end

  def each
    return to_enum unless block_given?

    read { |obj| yield obj } until eof
  end

  def eof?
    inbox.empty? && io.eof?
  end

  alias_method :eof, :eof?

  def flush_buffer
    self
  end

  def flush_outbox
    outbox.each { |obj| write_to_stream(obj.is_a? Proc ? obj.call : obj) }
    outbox.clear

    self
  end

  def read
    if block_given?
      read_from_inbox { |obj| yield obj }
      read_from_stream { |obj| yield obj }

      nil
    else
      read_one
    end
  end

  def read_from_stream
    yield Marshal.load(io)
  rescue IOError, SystemCallError
    raise
  rescue => e
    raise StreamError, "Unreadble stream: #{e}"
  end

  def read_one
    return inbox.shift unless inbox.empty?

    result = nil

    read { |obj| result.nil? ? result = obj : (inbox << obj) } while result.nil?

    result
  end

  def to_io
    io
  end

  def write(*objects)
    write_to_buffer(*objects)
    flush_buffer
  end

  alias_method :<<, :write

  def write_to_buffer(*objects)
    flush_outbox
    objects.each { |object| write_to_stream object }

    self
  end

  def write_to_outbox(object = nil, &block)
    outbox << (block || object)

    flush_outbox if outbox.size > max_outbox

    self
  end

  def write_to_stream(object)
    Marshal.dump(object, io)

    self
  end

  private

  attr_reader :inbox
  attr_reader :outbox

  def read_from_inbox
    return if inbox.empty?

    inbox.each { |obj| yield obj }
    inbox.clear
  end
end
