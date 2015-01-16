module Aggro
  # Public: Mixin to turn a PORO into an Aggro aggregate.
  module Aggregate
    extend ActiveSupport::Concern

    # Public: Adds class interface to aggregate.
    module ClassMethods
      def find(id)
        AggregateRef.new id, name
      end
    end
  end
end
