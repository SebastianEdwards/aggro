module Aggro
  module Transform
    # Private: Transforms money representations.
    module TimeInterval
      module_function

      def deserialize(value)
        if value.is_a? ::String
          ::TimeInterval.parse(value)
        elsif interval? value
          value
        end
      end

      def interval?(value)
        value.class.parents.include? ::TimeInterval
      end

      def serialize(value)
        value.iso8601 if interval? value
      end
    end
  end
end
