module Aggro
  module Transform
    # Private: Transforms boolean representations.
    module Boolean
      module_function

      def deserialize(value)
        value if value == false || value == true
      end

      def serialize(value)
        value if value == false || value == true
      end
    end
  end
end
