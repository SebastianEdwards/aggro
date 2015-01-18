module Aggro
  class AggregateChannel
    def initialize(id)
      @id = id
    end

    def forward_command(command)
      aggregate << command
    end

    private

    def aggregate
      @aggregate ||= AggregateLoader.spawn @id
    end
  end
end
