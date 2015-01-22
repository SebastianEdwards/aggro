module Aggro
  # Public: Mixin to turn a PORO into an Aggro command.
  module Command
    extend ActiveSupport::Concern
    include AttributeDSL

    included do
      generate_id :causation_id
      generate_id :correlation_id
    end

    def to_details
      { name: model_name.name, args: serialized_attributes }
    end
  end
end
