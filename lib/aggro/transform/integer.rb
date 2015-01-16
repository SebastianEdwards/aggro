module Transform
  # Private: Transforms integer representations.
  module Integer
    module_function

    def deserialize(value)
      if value.is_a?(::String)
        string = value.gsub(/[^\d\.]/, '')

        string == '' ? nil : string.to_i
      else
        value.to_i
      end
    end

    def serialize(value)
      value.to_i
    end
  end
end
