module Aggro
  module Transform
    # Private: Transforms boolean representations.
    module Boolean
      module_function

      def deserialize(value)
        value if truthy?(value) || falsey?(value)
      end

      def serialize(value)
        value if truthy?(value) || falsey?(value)
      end

      def falsey?(value)
        value == false || value == 'false' || value == '0'
      end

      private :falsey?

      def truthy?(value)
        value == true || value == 'true' || value == '1'
      end

      private :truthy?
    end
  end
end
