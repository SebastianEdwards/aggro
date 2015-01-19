module Aggro
  # Private: Helper to hashify a method call.
  module ArgumentHashifier
    module_function

    def hashify(parameters, arguments)
      {}.tap do |hash|
        required_positionals(parameters).each do |param|
          hash[param] = arguments.shift
        end

        keyword_arguments = arguments.last.is_a?(Hash) ? arguments.pop : {}
        hash.merge! keyword_arguments
      end
    end

    def required_positionals(parameters)
      parameters.select { |type, _| type == :req }.map(&:last)
    end
  end
end
