module Aggro
  # Private: Provides an interface to communicate with an Aggregate. Only
  #          loads the aggregate when needed.
  class AggregateChannel
    def initialize(stream)
      @stream = stream
    end

    def forward_command(command)
      aggregate << command if handles_command?(command)
    end

    def handles_command?(command)
      aggregate_class.allows? command.class
    end

    private

    def aggregate
      @aggregate ||= begin
        raw_aggregate = aggregate_class.new(@stream.id, @stream.events)
        ConcurrentAggregate.spawn! @stream.id, raw_aggregate
      end
    end

    def aggregate_class
      @aggregate_class ||= ActiveSupport::Inflector.constantize @stream.type
    end
  end
end
