module Aggro
  # Public: Mixin to turn a PORO into an Aggro projection.
  module Projection
    extend ActiveSupport::Concern
    include EventDSL

    def project
    end
  end
end
