module Aggro
  # Public: Mixin to turn a PORO into an Aggro class.
  module Command
    def self.included(klass)
      klass.send :include, ActiveModel::Validations
    end

    def to_details
      { name: self.class.to_s }
    end
  end
end
