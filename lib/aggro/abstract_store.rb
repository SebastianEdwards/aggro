module Aggro
  # Private: Abstract class for an event store.
  class AbstractStore
    def read(_refs)
      fail NotImplementedError
    end

    def write(_event_streams)
      fail NotImplementedError
    end
  end
end
