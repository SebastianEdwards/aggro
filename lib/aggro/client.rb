module Aggro
  # Public: Makes requests against a given endpoint returning parsed responses.
  class Client
    DEFAULT_POOL_SIZE = 16

    def initialize(endpoint, pool_size = DEFAULT_POOL_SIZE)
      @pool = Queue.new
      @pool_size = pool_size

      pool_size.times { @pool << Aggro.transport.client(endpoint) }
    end

    def disconnect!
      pool_size.times { pool.pop.close_socket }
    end

    def post(message)
      client = pool.pop

      MessageParser.parse client.post message
    ensure
      pool << client
    end

    private

    attr_reader :pool
    attr_reader :pool_size
  end
end
