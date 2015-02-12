module Aggro
  module Transform
    # Private: Transforms string representations.
    module String
      module_function

      def deserialize(value)
        value.to_s unless value.nil?
      end

      def serialize(value)
        value.to_s unless value.nil?
      end
    end
  end
end
