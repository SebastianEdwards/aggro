module Aggro
  # Public: Mixin to turn a PORO into an Aggro query.
  module Query
    extend ActiveSupport::Concern
    include AttributeDSL

    def to_details
      { name: model_name.name, args: serialized_attributes }
    end
  end
end
