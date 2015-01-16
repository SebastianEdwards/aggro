module Aggro
  # Public: Mixin to turn a PORO into an Aggro command.
  module Command
    extend ActiveSupport::Concern
    include ActiveModel::Model

    def attributes
      {}
    end

    def to_details
      { name: model_name.name, args: attributes }
    end
  end
end
