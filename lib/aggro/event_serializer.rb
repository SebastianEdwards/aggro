module Aggro
  # Public: Converts events to and from serialized data.
  module EventSerializer
    module_function

    def deserialize(serialized)
      Marshal.load serialized
    end

    def serialize(deserialized)
      Marshal.dump deserialized
    end
  end
end
