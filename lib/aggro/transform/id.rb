module Transform
  # Private: Transforms integer representations.
  class ID
    ID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

    def initialize(generate: false)
      @generate = generate
    end

    def deserialize(value)
      value = value.to_s

      return value if value.match(ID_REGEX)

      generate_id if should_generate_id?
    end

    def serialize(value)
      deserialize value
    end

    private

    def generate_id
      @generated_id ||= SecureRandom.uuid
    end

    def should_generate_id?
      @generate == true
    end
  end
end
