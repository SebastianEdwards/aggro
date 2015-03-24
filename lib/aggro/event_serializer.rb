module Aggro
  # Public: Converts events to and from serialized data.
  module EventSerializer
    module_function

    def deserialize(serialized)
      Event.new(serialized[0], Time.parse(serialized[1]), serialized[2])
    end

    def serialize(deserialized)
      [deserialized.name, deserialized.occured_at.iso8601, deserialized.details]
    end
  end
end
