module Aggro
  module Transform
    # Private: Transforms time representations.
    module Time
      module_function

      def deserialize(value)
        if value.is_a? ::String
          ::Time.parse(value)
        elsif value.is_a? ::Integer
          ::Time.parse(value.to_s)
        elsif value.is_a? ::Time
          value
        end
      end

      def serialize(value)
        value.to_s if value.is_a? ::Time
      end
    end
  end
end
