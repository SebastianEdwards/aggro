module Aggro
  module Transform
    # Private: Transforms money representations.
    module Money
      module_function

      def deserialize(value)
        if value.is_a? ::String
          Monetize.parse(value)
        elsif value.is_a? ::Integer
          Monetize.parse(value.to_s)
        elsif value.is_a? ::Money
          value
        end
      end

      def serialize(value)
        value.format with_currency: true if value.is_a? ::Money
      end
    end
  end
end
