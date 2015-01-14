module Aggro
  # Public: Parses inter-node messages and routes them to attached handlers.
  class MessageRouter
    def initialize
      @handlers = {}
    end

    def attach_handler(message_type, callable = nil, &block)
      if callable
        @handlers[message_type] = callable
      elsif block_given?
        @handlers[message_type] = block
      else
        fail ArgumentError
      end
    end

    def handles?(message_type)
      @handlers[message_type]
    end

    def route(message)
      type = MESSAGE_TYPES[message[0]]

      @handlers[type].call type.parse(message) if handles?(type)
    end
  end
end
