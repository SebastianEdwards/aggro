module Aggro
  class AggregateChannel
    def initialize(id)
      @id = id
    end

    def forward_command(command)
      aggregate << command
    end

    def handles_command?(command)
      aggregate.class.allows command.class
    end

    private

    def aggregate
      @aggregate ||= AggregateLoader.spawn @id
    end
  end
end
