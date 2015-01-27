module Aggro
  # Public: Converts events to and from serialized data.
  module EventSerializer
    module_function

    def deserialize(serialized)
      event_from_hash MessagePack.unpack(serialized, symbolize_keys: true)
    end

    def event_from_hash(hash)
      Event.new(hash[:n].to_sym, Time.at(hash[:t]),
                hash[:d])
    end

    def serialize(deserialized)
      MessagePack.pack(n: deserialized.name, t: deserialized.occured_at.to_i,
                       d: deserialized.details)
    end
  end
end
