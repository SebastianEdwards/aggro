module Aggro
  module Transform
    # Private: No op transform.
    module NOOP
      module_function

      def deserialize(value)
        value
      end

      def serialize(value)
        value
      end
    end
  end
end
