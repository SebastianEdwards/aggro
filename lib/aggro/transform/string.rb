module Transform
  # Private: Transforms string representations.
  module String
    module_function

    def deserialize(value)
      value.to_s
    end

    def serialize(value)
      value.to_s
    end
  end
end
