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

    private

    def target
      @target ||= begin
        ConcurrentActor.spawn! id, target_class.new(id)
      end
    end

    def target_class
      @target_class ||= ActiveSupport::Inflector.constantize type
    end
  end
end
