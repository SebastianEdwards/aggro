module Aggro
  # Public: Parses inter-node messages.
  module MessageParser
    module_function

    def parse(message)
      MESSAGE_TYPES[message[0..1]].parse message
    end
  end
end
