module Aggro
  # Public: Converts events to and from serialized data.
  module EventSerializer
    def self.deserialize(serialized)
      raw = MessagePack.unpack(serialized)

      Event.new(raw['n'], Time.at(raw['t']), raw['d'].deep_symbolize_keys!)
    end

    def self.serialize(deserialized)
      MessagePack.pack(n: deserialized.name, t: deserialized.occured_at.to_i,
                       d: deserialized.details)
    end
  end
end
