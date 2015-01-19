module Aggro
  # Private: Wraps a given aggregate in an concurrent actor.
  class ConcurrentAggregate < Concurrent::Actor::Context
    def initialize(aggregate)
      @aggregate = aggregate
    end

    def on_message(message)
      @aggregate.apply_command message if command?(message)
    end

    private

    def command?(message)
      message.class.included_modules.include? Command
    end
  end
end
