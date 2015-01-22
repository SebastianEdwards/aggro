module Aggro
  # Private: Wraps a given target in an concurrent actor.
  class ConcurrentActor < Concurrent::Actor::Context
    def initialize(target)
      @target = target
    end

    def on_message(message)
      @target.send :apply_command, message if @target.class.allows? message
    end
  end
end
