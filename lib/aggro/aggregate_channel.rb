module Aggro
  # Private: Provides an interface to communicate with an Aggregate. Only
  #          loads the aggregate when needed.
  class AggregateChannel
    def initialize(id, type)
      @id = id
      @type = type
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
        raw_aggregate = aggregate_class.new(@id)
        ConcurrentAggregate.spawn! @id, raw_aggregate
      end
    end

    def aggregate_class
      @aggregate_class ||= ActiveSupport::Inflector.constantize @type
    end
  end
end
