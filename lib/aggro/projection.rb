module Aggro
  # Public: Mixin to turn a PORO into an Aggro projection.
  module Projection
    extend ActiveSupport::Concern
    include EventDSL

    def initialize(id)
      Aggro.event_bus.subscribe(self, id)
    end

    def project
    end
  end
end
