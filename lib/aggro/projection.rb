module Aggro
  # Public: Mixin to turn a PORO into an Aggro projection.
  module Projection
    extend ActiveSupport::Concern

    include BindingDSL
    include EventDSL

    def initialize(id)
      Aggro.event_bus.subscribe(id, self)
    end
  end
end
