module Aggro
  # Private: Provides an interface to communicate with an aggregate or saga.
  #          Only loads the target object when needed.
  class Channel < Struct.new(:id, :type)
    def forward_command(command)
      target << command if handles_command?(command)
    end

    def handles_command?(command)
      target_class.allows? command
    end

    def handles_query?(query)
      target_class.responds_to? query
    end

    def run_query(query)
      target.ask query if handles_query? query
    end

    private

    def target
      @target ||= begin
        ConcurrentActor.spawn!(
          name: id,
          args: [target_class.new(id)],
          executor: Concurrent.configuration.global_operation_pool
        )
      end
    end

    def target_class
      @target_class ||= ActiveSupport::Inflector.constantize type
    end
  end
end
