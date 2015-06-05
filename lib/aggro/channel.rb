module Aggro
  # Private: Provides an interface to communicate with an aggregate or saga.
  #          Only loads the target object when needed.
  class Channel
    attr_reader :id, :type

    def initialize(id, type)
      @id = id
      @type = type
      @load_mutex = Mutex.new
    end

    def forward_command(command)
      return unless target

      concurrent_target << command if handles_command?(command)
    end

    def handles_command?(command)
      target_class.allows? command
    end

    def handles_query?(query)
      target_class.responds_to? query
    end

    def run_fast_query(query)
      return QueryError.new 'Could not initialize aggregate' unless target

      target.send :run_query, query
    end

    def run_query(query)
      unless target
        error = QueryError.new 'Could not initialize aggregate'
        return Concurrent::IVar.new error
      end

      concurrent_target.ask query if handles_query? query
    end

    private

    def target
      @target ||= @load_mutex.synchronize do
        return @target if @target

        target_class.new(id)
      end
    rescue
      nil
    end

    def concurrent_target
      @concurrent_target ||= begin
        ConcurrentActor.spawn!(
          name: id,
          args: [target],
          executor: Concurrent.configuration.global_task_pool
        )
      end
    end

    def target_class
      @target_class ||= ActiveSupport::Inflector.constantize type
    end
  end
end
