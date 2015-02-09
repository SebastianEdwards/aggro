module Aggro
  module Transform
    # Private: Transforms date representations.
    module Date
      module_function

      def deserialize(value)
        if value.is_a? ::String
          ::Date.parse(value)
        elsif value.is_a? ::Integer
          ::Date.parse(value.to_s)
        elsif value.is_a? ::Date
          value
        end
      end

      def serialize(value)
        value.to_s if value.is_a? ::Date
      end
    end
  end
end
