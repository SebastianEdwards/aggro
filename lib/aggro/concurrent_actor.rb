module Aggro
  # Private: Wraps a given target in an concurrent actor.
  class ConcurrentActor < Concurrent::Actor::RestartingContext
    def initialize(target)
      @target = target
    end

    def on_message(message)
      if command? message
        @target.send :apply_command, message
      elsif query? message
        @target.send :run_query, message
      end
    end

    private

    def command?(message)
      message.class.included_modules.include? Command
    end

    def query?(message)
      message.class.included_modules.include? Query
    end
  end
end
