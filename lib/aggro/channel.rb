module Aggro
  # Private: Provides an interface to communicate with an aggregate or saga.
  #          Only loads the target object when needed.
  class Channel
    attr_reader :id, :type

    def initialize(id, type)
      @id = id
      @type = type
    end

    def forward_command(command)
      return unless target

      target << command if handles_command?(command)
    end

    def handles_command?(command)
      target_class.allows? command
    end

    def handles_query?(query)
      target_class.responds_to? query
    end

    def run_query(query)
      unless target
        error = QueryError.new 'Could not initialize aggregate'
        return Concurrent::IVar.new error
      end

      target.ask query if handles_query? query
    end

    private

    def target
      @target ||= begin
        ConcurrentActor.spawn!(
          name: id,
          args: [target_class.new(id)],
          executor: Concurrent.configuration.global_task_pool
        )
      rescue
        nil
      end
    end

    def target_class
      @target_class ||= ActiveSupport::Inflector.constantize type
    end
  end
end
