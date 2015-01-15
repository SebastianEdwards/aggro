module Aggro
  # Public: Mixin to turn a PORO into an Aggro class.
  module Command
    def self.included(klass)
      klass.send :include, ActiveModel::Model
    end

    def attributes
      {}
    end

    def to_details
      { name: model_name.name, args: attributes }
    end
  end
end
