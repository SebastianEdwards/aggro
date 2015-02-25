module Aggro
  # Public: Converts events to and from serialized data.
  module EventSerializer
    module_function

    def deserialize(serialized)
      Event.new(*serialized)
    end

    def serialize(deserialized)
      [deserialized.name, deserialized.occured_at, deserialized.details]
    end
  end
end
