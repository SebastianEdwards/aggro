module Aggro
  # Public: Routes inter-node messages to attached message handlers.
  class MessageRouter
    def initialize
      @handlers = {}
    end

    def attach_handler(message_class, callable = nil, &block)
      if callable
        @handlers[message_class] = callable
      elsif block_given?
        @handlers[message_class] = block
      else
        fail ArgumentError
      end
    end

    def handles?(message_class)
      @handlers[message_class]
    end

    def route(message)
      @handlers[message.class].call message if handles?(message.class)
    end
  end
end
