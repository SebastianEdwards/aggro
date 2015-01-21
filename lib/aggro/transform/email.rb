module Aggro
  module Transform
    # Private: Transforms integer representations.
    module Email
      EMAIL_REGEX = %r{
        \A([-a-z0-9!\#$%&'*+/=?^_`{|}~]+\.)*
        [-a-z0-9!\#$%&'*+/=?^_`{|}~]+
        @
        ((?:[-a-z0-9]+\.)+
        [a-z]{2,})\Z
      }xi

      module_function

      def deserialize(value)
        value = value.to_s

        value if value.match(EMAIL_REGEX)
      end

      def serialize(value)
        deserialize value
      end
    end
  end
end
