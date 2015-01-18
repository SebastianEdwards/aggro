module Aggro
  module AggregateLoader
    module_function

    def class_for_type(type)
      ActiveSupport::Inflector.constantize type
    end

    def spawn(id)
      spawn_with_stream Aggro.store.read([id]).first
    end

    def spawn_with_stream(stream)
      aggregate = class_for_type(stream.type).new(stream.id, stream.events)

      ThreadedAggregate.spawn!(stream.id, aggregate)
    end
  end
end
