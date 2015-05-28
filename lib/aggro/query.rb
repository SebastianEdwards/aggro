module Aggro
  # Public: Mixin to turn a PORO into an Aggro query.
  module Query
    extend ActiveSupport::Concern
    include AttributeDSL

    class_methods do
      def timeout(value = nil)
        if value.present?
          @timeout = value
        else
          @timeout || 5
        end
      end
    end

    def to_details
      { name: model_name.name, args: serialized_attributes }
    end
  end
end
